#!/usr/bin/env Rscript

DOC_tweet_post = function(tweet_text) {

  suppressPackageStartupMessages({
    library(glue)
    library(rtweet)
  })

  APP_NAME = Sys.getenv("NJDOCcovid19_APP_NAME")

  token = create_token(
    app = APP_NAME,
    consumer_key = Sys.getenv("NJDOCcovid19_CONSUMER_KEY"),
    consumer_secret = Sys.getenv("NJDOCcovid19_CONSUMER_SECRET"),
    access_token = Sys.getenv("NJDOCcovid19_ACCESS_TOKEN"),
    access_secret = Sys.getenv("NJDOCcovid19_ACCESS_SECRET"))

  post_tweet(tweet_text, token = token)
  message(glue("Posted the following tweet with app {APP_NAME}:\n\n",
               "'{tweet_text}'"))

  invisible()

}
