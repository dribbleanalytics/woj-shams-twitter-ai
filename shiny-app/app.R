library(shiny)
library(shinythemes)
library(reticulate)

#reticulate::use_python('C:/Users/tboge/Anaconda3')

#reticulate::source_python('shiny_twitter.py')

#woj_info <- prep_data('wojespn_tweets.csv', 'woj_model.h5')
#shams_info <- prep_data('shamscharania_tweets.csv', 'shams_model.h5')

reticulate::virtualenv_create(envname = 'py3', 
                              python = 'python3')

reticulate::virtualenv_install('py3', 
                               packages = c('numpy', 'keras', 'pandas', 'tensorflow==2.0.0'))

reticulate::use_virtualenv('py3', required = T)

reticulate::source_python('shiny_twitter.py')

woj_info <- prep_data('wojespn_tweets.csv', 'woj_model.h5')
shams_info <- prep_data('shamscharania_tweets.csv', 'shams_model.h5')


ui <- fluidPage(theme = shinytheme('paper'),
                
                titlePanel("Generating fake Woj and Shams tweets with AI"),
                
  
                tabsetPanel(
                  tabPanel("Introduction", fluid = TRUE,
                           
                           mainPanel(
                             h1('Methods'),
                             p("To generate fake Woj and Shams tweets with AI, we trained an LSTM on the previous 3200 tweets from Woj and Shams. We created individual models
                                for each reporter (as they have different data). This app allows you to predict the next n words the model predicts for some sequence of
                                starting words. Note that after a certain point, the sentence will not make sense because that is where the tweet usually ends. So, large
                                numbers of predicted future words won't necessarily mean more information.", style = "font-size:16px"),
                             br(),
                             p("The models have several other nuances which we will not discuss here. For more information about the models and project, click on
                                either the blog link or GitHub link below.", style = "font-size:16px"),
                             h1("Links"),
                             a(href="https://dribbleanalytics.blog/2020/02/woj-shams-twitter-ai",
                               div("Click here to see the original blog post which includes a more detailed discussion of methods and results.", style = 'font-size:16px')),
                             br(),
                             a(href="https://github.com/dribbleanalytics/woj-shams-twitter-ai/",
                               div("Click here to see the GitHub repository for the project which contains all code, data, and results.", style = 'font-size:16px'))
                             
                             )
                           ),
                  tabPanel("Prediction", fluid = TRUE,
                           sidebarLayout(
                             sidebarPanel(p("To predict the next n words, first write your starting sequence of words. Then, select the number of following words you'd
                                              like the models to predict", style = 'font-size:16px'),
                                          br(),
                                          
                                          textInput(inputId = "seedtext",
                                                    label = "Input starting text:",
                                                    value = ""),
                                                    
                                          numericInput(inputId = "n_words",
                                                       label = "Words predicted (max 50):",
                                                       value = 20,
                                                       min = 1,
                                                       max = 50),
                                          
                                          br(),
                                          
                                          p("Note that usually, Shams tweets starting with \"Sources:\" usually turn out better than those starting with just
                                             the player or team name, while Woj tweets starting with just the name usually turn out better than those starting
                                             with \"Sources:\".", style = 'font-size:16px')
                             ),
                             mainPanel(h1("Woj predicted tweet:"),
                                          span(textOutput(outputId = "woj_tweet"), style = 'font-size:16px'),
                                          br(),
                                          h1("Shams predicted tweet:"),
                                          span(textOutput(outputId = "shams_tweet"), style = 'font-size:16px')
                             )
                           )
                  )
                )
)
                  
                  
                




server <- function(input, output) {
  
  
  output$woj_tweet <- renderText({
    
    generate_text(input$seedtext, input$n_words, woj_info[[1]], woj_info[[2]], woj_info[[3]])
  
  })
  
  output$shams_tweet <- renderText({
    
    generate_text(input$seedtext, input$n_words, shams_info[[1]], shams_info[[2]], shams_info[[3]])
    
    
  })
  
}

shinyApp(ui = ui, server = server)
