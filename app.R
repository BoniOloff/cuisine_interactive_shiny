library(tidyverse)
library(shiny)
library(DT)
library(d3wordcloud)
library(plotly)

data <- readRDS("recipes.rds")
data <- data %>% 
    tidyr::unnest_longer(col = ingredients, values_to = "Ingredient") %>% 
    select(-id)
tfidf_data <- data %>% 
    count(cuisine, Ingredient, name = "nb_recipes") %>% 
    tidytext::bind_tf_idf(Ingredient, cuisine, nb_recipes)

ui <- fluidPage(
    titlePanel("Cuisine Explorer"),

    sidebarLayout(
        # Sidebar Panel
        sidebarPanel(
            selectInput("cuisine", "Cuisine:", choices = unique(data$cuisine)),
            sliderInput("number_ingredients", "Number of Ingredients", 10, 100, 20)
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
    output$table <- renderDT({
        tfidf_data %>% 
            filter(cuisine == input$cuisine) %>% 
            arrange(desc(nb_recipes))
    })
    
    output$word_cloud <- renderD3wordcloud({
        d3wordcloud(tfidf_data$Ingredient, tfidf_data$tf_idf, tooltip = TRUE)
    })
}

shinyApp(ui = ui, server = server)
