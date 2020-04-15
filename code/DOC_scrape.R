library(dplyr)
library(glue)
library(purrr)
library(readr)
library(rvest)
library(stringr)

src = read_html("https://njdoc.gov/pages/COVID19Updates.shtml")

tables = src %>%
  html_nodes(css = ".align-text-top .table-striped") %>%
  html_table()

timestamps = src %>%
  html_nodes(css = ".align-text-top p") %>%
  html_text() %>%
  str_extract("\\d+/\\d+/\\d{4} \\d+:\\d+:\\d+ (AM|PM)") %>%
  as.POSIXct(format = "%m/%d/%Y %I:%M:%S %p")

data_out = map2_dfr(.x = tables, .y = timestamps,
                    ~{
                      .x %>%
                        mutate(as_of = .y,
                               system = names(.)[1]) %>%
                        rename(location = 1) %>%
                        rename_all(tolower) %>%
                        select(as_of, system, location, everything())
                    })

datestamp = strftime(timestamps[1], "%Y-%m-%d")
write_csv(data_out, glue("data/DOC/NJ_DOC_COVID-19-Updates_{datestamp}.csv"))
