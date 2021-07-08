library(tidyverse)
library(shiny)
library(DT)
library(d3wordcloud)
library(plotly)

data <- readRDS("recipes.rds")

data <- data %>% 
    tidyr::unnest_longer(col = ingredients, values_to = "Ingredient")

tfidf_data <- data %>% 
    count(cuisine, Ingredient, name = "nb_recipes") %>% 
    tidytext::bind_tf_idf(Ingredient, cuisine, nb_recipes)

ui <- fluidPage(
    titlePanel("Cuisine Explorer"),

    sidebarLayout(
        # Sidebar Panel
        sidebarPanel(
            selectInput("cuisine", "Cuisine:", choices = unique(tfidf_data$cuisine)),
            sliderInput("number_ingredients", "Number of Ingredients", 10, 100, 20),
            actionButton('show_about', 'About')
        ),

        # Main Panel
        mainPanel(
           tabsetPanel(
               tabPanel("Word Cloud", d3wordcloudOutput("word_cloud")),
               tabPanel("Plot", plotly::plotlyOutput("plot")),
               tabPanel("Table", DTOutput("table"))
           )
        )
    )
)

server <- function(input, output) {
    top_ingredients <- reactive({
        tfidf_data %>% 
            filter(cuisine == input$cuisine) %>% 
            arrange(desc(tf_idf)) %>% 
            head(input$number_ingredients) %>% 
            mutate(Ingredient = forcats::fct_reorder(Ingredient, tf_idf))
    })
    
    output$table <- renderDT({
        tfidf_data %>% 
            filter(cuisine == input$cuisine) %>% 
            arrange(desc(nb_recipes))
    })
    
    output$word_cloud <- renderD3wordcloud({
        d <- top_ingredients()
        d3wordcloud(d$Ingredient, d$nb_recipes, tooltip = TRUE)
    })
    
    output$plot <- renderPlotly({
        d <- top_ingredients()
        d %>% 
            ggplot(mapping = aes(x = Ingredient, y = tf_idf)) +
            geom_col() +
            labs(x = "", y = "TF-IDF", title = "Top Important Ingredients") +
            coord_flip()
    })
    
    text_about <- "More description here: https://github.com/BoniOloff/cuisine_interactive_shiny"
    observeEvent(input$show_about, {
        showModal(modalDialog(text_about, title = 'About'))
    })
}

shinyApp(ui = ui, server = server)
