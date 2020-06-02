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
  as.POSIXct(format = "%m/%d/%Y %I:%M:%S %p",
             # Appends timezone to end of each date string
             tz = "EST", usetz = TRUE)

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

# Fix colnames: `inmate deaths` --> inmate_deaths
names(data_cases) = gsub(" ", "_", names(data_cases))


##%######################################################%##
#                                                          #
####                    Testing Data                    ####
#                                                          #
##%######################################################%##

testing_txt = src %>%
  # "div.standard_font i" until 2020-04-27 data
  html_nodes(css = "em") %>%
  html_text() %>%
  str_squish()

NUM_PAT = "\\b(\\d+,)?\\d+\\b"

rgx_lookahead = function(pat) {
  str_extract(testing_txt, glue("{NUM_PAT}(?={pat})"))
}

# rgx_lookbehind = function(pat) {
#   str_extract(testing_txt, glue("(?<={pat})\\d+"))
# }

library(english)
nums = 1:1000
nums_english = english(nums) %>% as.character()
english_to_num = function(eng) {
  if (as.numeric(eng) %in% nums) {
    eng
  } else {
    nums[nums_english == eng]
  }
}

# I noticed on 2020-06-02:
# "As of 5/30/2020 all NJDOC Facilities, RCRP and Assessment Center inmates have
#  been tested. A number of lab results are still pending."
# So I'm commenting out the below:
#
# # A tibble w/ 1 row
# data_testing = tibble(as_of = testing_txt %>%
#                         str_extract("\\d+/\\d+/\\d{4}") %>%
#                         as.Date(format = "%m/%d/%Y"),
#                       tested   = rgx_lookahead(" tests"),
#                       positive = rgx_lookahead(" positive"),
#                       negative = rgx_lookahead(" negative"),
#                       pending  = rgx_lookahead(" pending"))
#
# data_testing_date = data_testing$as_of[1]
#
# # On 5/15, there are several issues:
# #   - 3198 tested, 602 positive, 2596 negative
# #       - # pending isn't reported at all
# #       - On 5/14, the #s reported were 609 tested,	544 positive,	61 negative,
# #         4 pending.
# #   - Datestamp for testing data is 5/14, vs 5/15 for cases data
# if (any(sapply(data_testing[ , 2:4], is.na))) {
#   stop("Something went wrong when parsing testing data text.")
# }
# # Testing and case data each have timestamps. They _should_ be equal, but we'll
# # notice if they ever differ.
# if (data_testing_date != datestamp) {
#   stop("Testing and cases data datestamps differ.")
# }


##%######################################################%##
#                                                          #
####                      Archive                       ####
#                                                          #
##%######################################################%##

write_csv(data_cases,
          glue("{WRITE_DIR}/NJ_DOC_COVID-19-Locations_{datestamp}.csv"))

# testing_basename = "NJ_DOC_COVID-19-Summary"
# testing_path = glue("{WRITE_DIR}/Summary/{testing_basename}.csv")
#
# if (!file.exists(testing_path)) {
#   write_csv(data_testing, testing_path)
# } else {
#   old_data_testing = read_csv(testing_path,
#                               col_types = cols(as_of = col_date(),
#                                                tested = col_character(),
#                                                positive = col_character(),
#                                                negative = col_character(),
#                                                pending = col_character()))
#
#   latest_date_saved = max(old_data_testing$as_of)
#
#   if (latest_date_saved != data_testing_date) {
#     # pass
#   } else if (latest_date_saved == as.Date("2020-05-14")
#              & data_testing_date == as.Date("2020-05-14")) {
#     data_testing_date = as.Date("2020-05-15")
#     data_testing$as_of = data_testing_date
#   } else {
#     message(glue("There's already summary data saved for {data_testing_date}."))
#   }
# }
#
# bind_rows(old_data_testing, data_testing) %>%
#   write_csv(testing_path)
#
# message(glue("Data successfully scraped and saved for {data_testing_date}."))
