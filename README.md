# METHODOLOGY: Generating fake Woj and Shams tweets with AI

[Link to blog post.](https://dribbleanalytics.blog/2020/02/woj-shams-twitter-ai)

## Data collection

Using tweepy, we collected the past 3200 tweets from Andrian Wojnarowski and Shams Charania on 2/6/2020 at 4:00PM EST. The data is available in the "final-csv-data" folder.

With the csv files of their tweets, we converted each tweet to a sequence of text. Then, we assigned each word to a number to create sequences of numbers to feed our model.

## The model

Note that Woj and Shams had separate models, though both their models were constructed the exact same way. Only the data was different.

We created a single-layer LSTM with 256 units. Before entering the LSTM layer, the data was processed by a word embeddings layer that projected our word vectors into 16 dimensions. This made the model much faster without sacrificing accuracy.

We trained the model with categorical cross-entropy loss on 100 epochs.

Given any seed text, the model can predict any number of future words.

## The results

In our blog post, we discussed some generated tweets from seed text that included popular players and teams. However, the models can predict tweets for any seed text.

We created an R Shiny app to allow users to interact with the model. The app allows a user to input any seed text (starting words) and any number of words (less than 50) to predict. The app is available here:

https://dribbleanalytics.shinyapps.io/woj-shams-twitter-ai/
