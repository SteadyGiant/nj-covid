#!/usr/bin/env Rscript

DOC_tweet_post = function(tweet_text) {

  suppressPackageStartupMessages({
    library(glue)
    library(rtweet)
  })

  APP_NAME = Sys.getenv("NJDOCcovid19_APP_NAME")

  token = create_token(
    app = APP_NAME,
    consumer_key = Sys.getenv("ZCSDUtrUVMrjU78JjJtaoxNyU"),
    consumer_secret =
      Sys.getenv("8jrTxpharfTO54YlAzW2QTJbloxsewlwM1X5YQdCfZB2ug62Hq"),
    access_token =
      Sys.getenv("1251978966291881984-3N02ABLExrUqmUk6d9EEPGzgQz5uDa"),
    access_secret = Sys.getenv("XiQ1SqnIqd7AaswgI7F1XQ65bmNpBdxF0QCB4g1a8cTeK"))

  post_tweet(tweet_text, token = token)
  message(glue("Posted the following tweet with app {APP_NAME}:\n\n",
               "'{tweet_text}'"))

  invisible()

}
