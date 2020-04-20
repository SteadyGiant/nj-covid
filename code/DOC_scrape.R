#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(glue)
  library(purrr)
  library(readr)
  library(rvest)
  library(stringr)
})

# Directory where scraped data will be saved. No slash at end.
WRITE_DIR = "data/DOC"
# Before 2020-04-20: https://njdoc.gov/pages/COVID19Updates.shtml
URL = "https://www.state.nj.us/corrections/pages/COVID19Updates.shtml"


##%######################################################%##
#                                                          #
####                     Cases Data                     ####
#                                                          #
##%######################################################%##

src = read_html(URL)

timestamps = src %>%
  html_nodes(css = ".align-text-top p") %>%
  html_text() %>%
  str_extract("\\d+/\\d+/\\d{4} \\d+:\\d+:\\d+ (AM|PM)") %>%
  as.POSIXct(format = "%m/%d/%Y %I:%M:%S %p")

# Prison and halfway house datasets each have a timestamp. They _should_ be
# equal, but we'll notice if they ever differ.
if (timestamps[1] != timestamps[2]) {
  stop("Prison and halfway house timestamps differ.")
} else {
  timestamp_ = timestamps[1]
  # as.Date rounds up
  datestamp = strftime(timestamp_, "%Y-%m-%d")
}

tables = src %>%
  html_nodes(css = ".align-text-top .table-striped") %>%
  html_table()

data_cases =
  map_dfr(.x = tables,
          ~{
            .x %>%
              mutate(as_of = timestamp_,
                     system = names(.)[1]) %>%
              rename(location = 1)
          }) %>%
  rename_all(tolower) %>%
  select(as_of, system, location, everything())


##%######################################################%##
#                                                          #
####                    Testing Data                    ####
#                                                          #
##%######################################################%##

testing_txt = src %>%
  html_nodes(css = "div.standard_font i") %>%
  html_text()

rgx_lookahead = function(pat) {
  str_extract(testing_txt, glue("\\d+(?={pat})"))
}

# A tibble w/ 1 row
data_testing = tibble(as_of = testing_txt %>%
                        str_extract("\\d+/\\d+/\\d{4}") %>%
                        as.Date(format = "%m/%d/%Y"),
                      tested   = rgx_lookahead(" inmates"),
                      positive = rgx_lookahead(" positive"),
                      negative = rgx_lookahead(" negative"),
                      pending  = rgx_lookahead(" pending"))

data_testing_date = data_testing$as_of[1]

# Testing and case data each have timestamps. They _should_ be equal, but we'll
# notice if they ever differ.
if (data_testing_date != datestamp) {
  stop("Testing and cases data datestamps differ.")
}


##%######################################################%##
#                                                          #
####                      Archive                       ####
#                                                          #
##%######################################################%##

write_csv(data_cases,
          glue("{WRITE_DIR}/NJ_DOC_COVID-19-Updates_{datestamp}.csv"))

testing_basename = "NJ_DOC_COVID-19-Summary"
testing_path = glue("{WRITE_DIR}/Summary/{testing_basename}.csv")

if (!file.exists(testing_path)) {
  write_csv(data_testing, testing_path)
} else {
  old_data_testing = read_csv(testing_path,
                              col_types = cols(as_of = col_date(),
                                               tested = col_character(),
                                               positive = col_character(),
                                               negative = col_character(),
                                               pending = col_character()))

  latest_date_saved = max(old_data_testing$as_of)

  if (latest_date_saved != data_testing_date) {
    bind_rows(old_data_testing, data_testing) %>%
      write_csv(testing_path)
  } else {
    message(glue("There's already summary data saved for {latest_date_saved}."))
  }
}
