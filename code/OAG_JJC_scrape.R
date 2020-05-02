#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(glue)
  library(readr)
  library(rvest)
  library(stringr)
  library(tidyr)
})

WRITE_DIR = "data/OAG_JJC"

src = read_html("https://www.nj.gov/oag/jjc/covid19-facilities.html")

up_date =
  html_node(src, ".secondLevelPageTitle strong") %>%
  html_text() %>%
  str_extract("\\d{2}\\/\\d+\\/\\d{2}") %>%
  as.POSIXct(format = "%m/%d/%y") %>%
  strftime("%Y-%m-%d")

locations_data =
  tibble(
    as_of = up_date,
    location = src %>%
      html_nodes(paste0("tr:nth-child(33) td:nth-child(1) strong , ",
                        "tr:nth-child(20) td:nth-child(1) strong, ",
                        "font strong")) %>%
      html_text() %>%
      str_squish(),
    cases = src %>%
      # Before 5/01: "td td td td td:nth-child(2) strong"
      html_nodes(
        "tr:nth-child(33) tr td:nth-child(2) strong , tr:nth-child(31) tr td:nth-child(2) strong, tr:nth-child(28) tr td:nth-child(2) strong, tr:nth-child(25) tr td:nth-child(2) strong, tr:nth-child(20) tr td:nth-child(2) strong, tr:nth-child(18) tr td:nth-child(2) strong, tr:nth-child(15) tr td:nth-child(2) strong, tr:nth-child(12) tr td:nth-child(2) strong, tr:nth-child(9) tr td:nth-child(2) strong") %>%
      html_text()
  ) %>%
  mutate(
    people = case_when(str_detect(location, "^Total.*Staff") ~ "Staff",
                       str_detect(location, "^Total.*Residents") ~ "Residents",
                       TRUE ~ NA_character_)
  ) %>%
  fill(people, .direction = "up") %>%
  mutate(
    location = str_remove(
      location,
      paste0("(?<=Total).*|",
             "Number of (Staff|Residents) Testing Positive for COVID-19 at "))
  ) %>%
  select(as_of, people, location, cases)

testing_info = src %>%
  html_nodes("em") %>%
  html_text()

pos_neg_pen = src %>%
  html_nodes(
    "tr:nth-child(38) tr td:nth-child(2) strong , tr:nth-child(37) tr td:nth-child(2) strong, tr:nth-child(36) tr td:nth-child(2) strong") %>%
  html_text() %>%
  as.numeric()

testing_data = tibble(
  as_of = testing_info %>%
    str_extract("\\d+\\/\\d+\\/\\d+") %>%
    as.Date("%m/%d/%Y"),
  tested = testing_info %>%
    str_extract("\\d+(?= JJC)"),
  positive = pos_neg_pen[1],
  negative = pos_neg_pen[2],
  pending  = pos_neg_pen[3]
)

locs_file_path = glue("{WRITE_DIR}/NJ_OAG_JJC_COVID-19_Locations_{up_date}.csv")
if (file.exists(locs_file_path)) {
  stop(glue("There's already juvenile data saved for {up_date}."))
} else {
  write_csv(locations_data, locs_file_path)
}

test_file_path = glue("{WRITE_DIR}/Summary/NJ_OAG_JJC_COVID-19_Summary.csv")
if (!file.exists(test_file_path)) {
  write_csv(testing_data, test_file_path)
} else {
  read_csv(test_file_path) %>%
    bind_rows(testing_data) %>%
    write_csv(test_file_path)
}

message(glue("Juvenile data successfully scraped and saved for {up_date}."))
