library(tidyverse)
library(shiny)
library(DT)
library(d3wordcloud)
library(plotly)

data <- readRDS("recipes.rds")

ui <- fluidPage(
    titlePanel("Cuisine Explorer"),

    sidebarLayout(
        # Sidebar Panel
        sidebarPanel(
            selectInput("cuisine", "Cuisine:", choices = unique(data$cuisine)),
            sliderInput("number_ingredients", "Number of Ingredients", 0, 100, 20)
        ),

        # Main Panel
        mainPanel(
           tabsetPanel(
               tabPanel("Word Cloud",
                        d3wordcloudOutput("word_cloud")
                        ),
               tabPanel("Plot",
                        plotly::plotlyOutput("plot")
                        ),
               tabPanel("Table",
                        DTOutput("table")
                        )
           )
        )
    )
)

server <- function(input, output) {

}

shinyApp(ui = ui, server = server)