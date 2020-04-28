#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(magrittr)
  library(readr)
})

source("code/utils/DOC_tweet_post.R")
source("code/utils/DOC_tweet_text.R")

# Get summary (testing) data for 2 most recent dates
testing_data = read_csv("data/DOC/Summary/NJ_DOC_COVID-19-Summary.csv")
# Get 2 most recent dates.
# NOTE: They don't report data on weekends, so you can't assume data is daily.
testing_data_tweet = testing_data %>%
  .[order(.$as_of, decreasing = TRUE), ] %>%  # descending
  .[1:2, ]

# Get system totals from most recent locations dataset
locations_data =
  list.files("data/DOC", pattern = "csv$", full.names = TRUE) %>%
  sort(decreasing = TRUE) %>%
  `[`(1:2) %>%
  lapply(read_csv) %>%
  do.call(rbind, .) %>%
  subset(location == "Totals")

tweet_text = DOC_tweet_text(locations_data, testing_data_tweet)
# Send tweet
DOC_tweet_post(tweet_text)
