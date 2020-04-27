#!/usr/bin/env Rscript

# This script does the following:
#   1. Changes timezone of `as_of` date in each 'NJ_DOC_COVID-19_Updates_*.csv'
#      file from UTC to EST, and appends timezone to the end of each date string
#   2. Changes filename of each 'NJ_DOC_COVID-19_Updates_*.csv' file to
#      'NJ_DOC_COVID-19_Locations_*.csv'
#   3. Renames variable `inmate deaths` to `inmate_deaths`

library(purrr)
library(readr)

paths_read = list.files("data/DOC/Old",
                        "Updates_\\d{4}-\\d{2}-\\d{2}\\.csv$",
                        full.names = TRUE)

new_basenames = paths_read %>%
  basename() %>%
  gsub("Updates", "Locations", .)

paths_write = paste0("data/DOC/", new_basenames)

paths_read %>%
  map(read_csv) %>%
  map(~{
    .x$as_of = format(.x$as_of, tz = "EST",
                      # Appends timezone to end of each date string
                      usetz = TRUE)
    names(.x) = gsub(" ", "_", names(.x))

    .x
  }) %>%
  walk2(.y = paths_write, ~write_csv(.x, .y))
