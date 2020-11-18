library(httr)
library(jsonlite)
library(curl)
library(glue)
library(readr)


apikey <- 'TWMTJGq6fwp86SnWS7lI1e8hSBgY2AEyKCp1R049nXdP'
url <- 'https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/e974bfb0-45fb-4ed8-a2b0-5f1c091bc997'

# Supported languages: https://cloud.ibm.com/docs/language-translator?topic=language-translator-translation-models

# Write function
watson_language_translator <- function(apikey, url, input_filepath, source_lang, target_lang) {

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

# Example
watson_language_translator(apikey = apikey,
                           url = url,
                           input_filepath = '~/developer/project_norwegian_defence/sample_russian_file.txt',
                           source_lang = 'ru',
                           target_lang = 'en')


translated_arabic <- watson_language_translator(apikey = apikey,
                           url = url,
                           input_filepath = '~/developer/project_norwegian_defence/sample_arabic_file.txt',
                           source_lang = 'ar',
                           target_lang = 'en')

write_lines(translated_arabic, path = "~/developer/project_norwegian_defence/sample_arabic_file_en.txt")



read_lines(file = "~/developer/project_norwegian_defence/sample_arabic_file.txt")

cat(watson_language_translator(apikey = apikey,
                               url = url,
                               input_filepath = '~/developer/project_norwegian_defence/sample_russian_file.txt',
                               source_lang = 'ru',
                               target_lang = 'en'))
