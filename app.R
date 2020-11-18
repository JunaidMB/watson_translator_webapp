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
  titlePanel("Watson Translator Webapp"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Upload Document
      shinyFilesButton("upload", "Upload Document to Translate" ,
                       title = "Select", multiple = FALSE,
                       buttonType = "default", class = NULL),
      
      #fileInput(inputId = "upload", label = "Upload Document to Translate", buttonLabel = "Upload"),
      
      # Input filepath
      #textInput(inputId = "filepath", label = "Filepath of Document to Translate"),
      
      # Source Language
      selectInput(inputId = 'source', label = 'Enter Source Language', choices = languages, selectize=FALSE),
      
      # Target Language
      selectInput(inputId = 'target', label = 'Enter Target Language', choices = languages, selectize=FALSE),
      
      actionButton(inputId = "run", label = "Run"),
      
      downloadButton(outputId = "download", label = "Download")
      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      h2("Translated Text"),
      
      textOutput(outputId = "translation")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  # Filepath 
  volumes <- getVolumes()
  shinyFileChoose(input, id = "upload", roots = volumes, session = session, filetypes = c("txt"))
  
  filepath <- reactive({
    
    req(input$upload)
    if(!is.null(input$upload)) {
      file_selected <- parseFilePaths(volumes, input$upload)
    }
    
    as.character(file_selected$datapath) 
    
    })
    

  
  translated_text <- eventReactive(input$run,
                                     { 
                                         
                                         watson_language_translator(apikey = Sys.getenv("apikey"),
                                                                    url = Sys.getenv("url"),
                                                                    input_filepath = filepath(),
                                                                    source_lang = input$source,
                                                                    target_lang = input$target) }) 
                                       
    
  output$translation <- renderText({translated_text()})
    
   
    
    output$download <- downloadHandler(
      filename = function() {
        paste0("translated_file_", input$target, ".txt")
      },
      content = function(file) {

          write_lines(translated_text(), path = file)

      }
    )
     
    

  
}

shinyApp(ui = ui, server = server)

