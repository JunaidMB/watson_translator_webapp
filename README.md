# Watson Natural Language Shiny Translator

This is a side project in which I've built a Google translate type clone in R Shiny. Instead of using the Google API, I have used the Watson Natural Language Translation service available from IBM. Further information about what this model is and what it can do can he found [here](https://cloud.ibm.com/docs/language-translator?topic=language-translator-gettingstarted). 

There are 2 branches in this repository - master and text_input_translation. The Shiny app in the master branch allows a document level translation provided the file we want to translate is saved in a local directory as a `.txt` file. The Shiny app in the text_input_translation branch allows the user to type in their own text and specify the target language to which they would like it translated. 

Due to the fact I'm using a [Lite](
https://cloud.ibm.com/catalog/services/language-translator) plan with the Watson Natural Language Translation service, I have restricted the input of the text to a maximum of 50 KB with UTF-8 encoding.

There is also a file called **watson_language_translator_all.R** which contains the R functions I use to connect to the Watson Natural Language Translator service along with examples of how they are used. If you wanted to use the service as part of some analysis you were doing, you could take them out of here as opposed to digging through the Shiny code.

## Watson Natural Language Translator Service

These apps are using my own personal instance with the Watson Natural Language Translator Service, for these to work on your computer you will require your [IBM Cloud](https://cloud.ibm.com/registration) account and a Watson Natural Language Translator Service instance which you can set up [here](
https://cloud.ibm.com/catalog/services/language-translator). Once you have set this up, you're going to need set up environmental variables and store them in a `.env` file and keep that in the same directory that holds your R files. The structure of the `.env` files should be:

```
apikey="PUTYOURAPIKEYHERE"
url="PUTYOURURLHERE"

```

Just to be safe, add an empty line as the final line in the `.env` file. Once this is in place, you should be all set to make all the functions and the Shiny apps work on your computer.

