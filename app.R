library(shiny)
library(shinyTime)
library(shinyFiles)
library(tidyverse)
library(glue)
library(DT)
library(plotly)
library(dotenv)
source("helper_functions.R")
load_dot_env()

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Watson Natural Language Translator"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Target Language
      selectInput(inputId = 'target_language', label = 'Enter Target Language', choices = languages, selectize=FALSE, selected = "en"),
      
      actionButton(inputId = "run", label = "Run")
      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      h2("Enter Text to Translate"),
      
      textAreaInput(inputId = "input_text", label = "Input Text", width = "1000px", height = "250px"),
      
      h2("Translated Text"),
      htmlOutput("translation")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  
  translated_text <- eventReactive(input$run, {
    
    
    output_object <- watson_language_auto_translate(input_text = input$input_text,
                                                    apikey = Sys.getenv("apikey"),
                                                    url = Sys.getenv("url"),
                                                    target_language = input$target_language)
    output_object$translations[,1]
  })
  
  output$translation <- renderText({ translated_text() })
  
  
  
}

shinyApp(ui = ui, server = server)

