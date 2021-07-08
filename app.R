#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

ui <- fluidPage(
    titlePanel("Cuisine Explorer"),

    sidebarLayout(
        # Sidebar Panel
        sidebarPanel(
            
        ),

        # Main Panel
        mainPanel(
           
        )
    )
)

server <- function(input, output) {

}

shinyApp(ui = ui, server = server)
