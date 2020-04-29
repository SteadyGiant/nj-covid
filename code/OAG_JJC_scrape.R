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
  str_extract("(\\d{2}/){2}\\d{2}") %>%
  as.POSIXct(format = "%m/%d/%y") %>%
  strftime("%Y-%m-%d")

file_path = glue("{WRITE_DIR}/NJ_OAG_JJC_COVID-19_Locations_{up_date}.csv")

if (file.exists(file_path)) {
  stop(glue("There's already juvenile data saved for {up_date}."))
}

locations_data =
  tibble(
    location = src %>%
      html_nodes(paste0("tr:nth-child(33) td:nth-child(1) strong , ",
                        "tr:nth-child(20) td:nth-child(1) strong, ",
                        "font strong")) %>%
      html_text() %>%
      str_squish() %>%
      str_remove_all(
        paste0("Number of (Staff|Residents) Testing Positive for COVID-19 at ",
               "|Overall | Total")),
    value = src %>%
      html_nodes("td td td td td:nth-child(2) strong") %>%
      html_text()
  ) %>%
  mutate(people = if_else(grepl("^(Resident|Staff)$", location),
                          location, NA_character_)) %>%
  fill(people, .direction = "up") %>%
  mutate(location = str_replace(location, "^(Resident|Staff)$", "Total")) %>%
  pivot_wider(id_cols = location, names_from = people, values_from = value)

total_row = locations_data %>%
  filter(location == "Total")

locations_data_cln = locations_data %>%
  filter(location != "Total") %>%
  arrange(location) %>%
  bind_rows(total_row)

write_csv(locations_data_cln, file_path)
message(glue("Juvenile data successfully scraped and saved for {up_date}."))
