#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(glue)
  library(purrr)
  library(readr)
  library(rvest)
  library(stringr)
})

src = read_html("https://njdoc.gov/pages/COVID19Updates.shtml")

timestamps = src %>%
  html_nodes(css = ".align-text-top p") %>%
  html_text() %>%
  str_extract("\\d+/\\d+/\\d{4} \\d+:\\d+:\\d+ (AM|PM)") %>%
  as.POSIXct(format = "%m/%d/%Y %I:%M:%S %p")

# Prison and halfway house datasets each have a timestamp. They _should_ be the
# same, but we'll notice if they ever differ.
if (timestamps[1] != timestamps[2]) {
  stop("Prison and halfway house timestamps differ.")
} else {
  timestamp_ = timestamps[1]
}

tables = src %>%
  html_nodes(css = ".align-text-top .table-striped") %>%
  html_table()

data_out =
  map_dfr(.x = tables,
          ~{
            .x %>%
              mutate(as_of = timestamp_,
                     system = names(.)[1]) %>%
              rename(location = 1)
          }) %>%
  rename_all(tolower) %>%
  select(as_of, system, location, everything())

datestamp = strftime(timestamp_, "%Y-%m-%d")
write_csv(data_out, glue("data/DOC/NJ_DOC_COVID-19-Updates_{datestamp}.csv"))
