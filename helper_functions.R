library(httr)
library(jsonlite)
library(curl)
library(glue)
library(readr)
library(stringi)
library(stringr)
library(utils)
library(dotenv)

# Direct Translation
watson_language_direct_translator <- function(input_text, apikey, url, source_language, target_language) {
  
  if (as.numeric(str_sub(format(object.size(input_text), units = "Kb", digits = 1),
                         end = -4)) >= 50 ) {
    
    response_data <- "Input Text too large, try something smaller"
  } else {
    
    headers = c(
      `Content-Type` = 'application/json'
    )
    
    params = list(
      `version` = '2018-05-01'
    )
    
    input_text_encoded <- stri_encode(input_text, unique(stri_enc_mark(input_text)), "UTF_8")
    
    model_id <- c(glue("{source_language}-{target_language}"))
    
    data <- toJSON(list(text = input_text_encoded, model_id = model_id), auto_unbox = TRUE)
    
    response <- httr::POST(url = glue('{url}/v3/translate'),
                           httr::add_headers(.headers=headers),
                           query = params,
                           body = data,
                           httr::authenticate('apikey', glue('{apikey}')))
    
    response_text <- content(response, type = 'text', encoding = 'UTF-8')
    response_data <- fromJSON(response_text)
  }
  
  return(response_data)
  
}

# Language Identifier
watson_language_identifier <- function(input_text, apikey, url) {
  headers = c(
    `Content-Type` = 'text/plain'
  )
  
  params = list(
    `version` = '2018-05-01'
  )
  
  response <- httr::POST(url = glue('{url}/v3/identify'),
                         httr::add_headers(.headers=headers), 
                         query = params, 
                         body = input_text, 
                         httr::authenticate('apikey',  glue('{apikey}')))
  
  response_text <- content(response, type = 'text', encoding = 'UTF-8')
  response_data <- fromJSON(response_text)
  
  return(response_data)
  
}

# Watson Auto-Identify and Translate
watson_language_auto_translate <- function(input_text, apikey, url, target_language) {
  
  languages_identification <- watson_language_identifier(input_text = input_text, apikey = apikey, url = url)
  
  source_language <- languages_identification[[1]][1,1]
  
  translated_text <- watson_language_direct_translator(input_text = input_text,
                                                       apikey = apikey,
                                                       url = url,
                                                       source_language = source_language,
                                                       target_language = target_language)
  
  return(translated_text)
}

# Document Translation
watson_language_document_translator <- function(apikey, url, input_filepath, source_lang, target_lang) {
  
  # Submit a document to translate
  params <-  list(
    `version` = '2018-05-01'
  )
  
  ## Submitting a form file
  body <- list(file = curl::form_file(path = glue("{input_filepath}") ),
               source = curl::form_data(value = glue("{source_lang}") ),
               target = curl::form_data(value = glue("{target_lang}") ))
  
  submit_response <- httr::POST(url = glue('{url}/v3/documents'),
                                body = body,
                                query = params,
                                httr::authenticate('apikey', glue('{apikey}')))
  
  submit_response_text <- content(submit_response, type = "text", encoding = 'UTF-8')
  submit_response_data <- fromJSON(submit_response_text)
  
  document_id <- submit_response_data$document_id
  
  
  repeat {
    # Check translated document status - Wait until it's done, wait every 5 seconds
    
    check_response <- httr::GET(url = glue('https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/e974bfb0-45fb-4ed8-a2b0-5f1c091bc997/v3/documents/{document_id}'),
                                query = params,
                                httr::authenticate('apikey', glue('{apikey}')) )
    
    check_response_text <- content(check_response, type = 'text', encoding = 'UTF-8')
    check_response_data <- fromJSON(check_response_text)
    
    # exit if the condition is met
    if (check_response_data$status == "available") break
    
    # Wait 5 seconds to try the loop again
    Sys.sleep(5)
  }
  
  # Download translated document
  download_response <- httr::GET(url = glue('https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/e974bfb0-45fb-4ed8-a2b0-5f1c091bc997/v3/documents/{document_id}/translated_document'),
                                 query = params,
                                 httr::authenticate('apikey', glue('{apikey}')) )
  
  download_text <- content(download_response, type = 'text', encoding = 'UTF-8')
  
  return(download_text)
  
}

# Vector of supported Languages
lang <- c('ar'
          ,'ko'
          ,'eu'
          ,'lv'
          ,'bn'
          ,'lt'
          ,'bs'
          ,'ms'
          ,'bg'
          ,'ml'
          ,'ca'
          ,'mt'
          ,'zh'
          ,'cnr'
          ,'zh-TW'
          ,'ne'
          ,'hr'
          ,'nb'
          ,'cs'
          ,'pl'
          ,'da'
          ,'pt'
          ,'nl'
          ,'ro'
          ,'en'
          ,'ru'
          ,'et'
          ,'sr'
          ,'fi'
          ,'si'
          ,'fr'
          ,'sk'
          ,'fr'
          ,'sl'
          ,'de'
          ,'es'
          ,'el'
          ,'sv'
          ,'gu'
          ,'ta'
          ,'he'
          ,'te'
          ,'hi'
          ,'th'
          ,'hu'
          ,'tr'
          ,'ga'
          ,'uk'
          ,'id'
          ,'ur'
          ,'it'
          ,'vi'
          ,'ja'
          ,'cy')

lang_names <- c('Arabic', 'Korean', 'Basque',
                'Latvian', 'Bengali', 'Lithuanian',
                'Bosnian', 'Malay', 'Bulgarian',
                'Malayalam', 'Catalan', 'Maltese',
                'Simplified Chinese', 'Montenegrin', 'Traditional Chinese',
                'Nepali', 'Croatian', 'Norwegian Bokmal',
                'Czech', 'Polish', 'Danish',
                'Portuguese', 'Dutch', 'Romanian',
                'English', 'Russian', 'Estonian',
                'Serbian', 'Finnish', 'Sinhala',
                'French', 'Slovak', 'Canadian French',
                'Slovenian', 'German', 'Spanish',
                'Greek', 'Swedish', 'Gujarati',
                'Tamil', 'Hebrew', 'Telugu',
                'Hindi', 'Thai', 'Hungarian',
                'Turkish', 'Irish', 'Ukrainian',
                'Indonesian', 'Urdu', 'Italian', 'Vietnamese',
                'Japanese', 'Welsh')

languages <- lang
names(languages) <- lang_names







