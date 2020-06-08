#!/usr/bin/env Rscript

DOC_tweet_text = function(locations_data, testing_data) {

  suppressPackageStartupMessages({
    library(glue)
    library(readr)
    library(rtweet)  # %>%
    library(scales)
  })

  DATA_URL = "https://gitlab.com/everetr/nj-covid-19"

  # Cannot allow ANY indentation beyond first line
  TWEET_PLAN = "{mdd}

Prisons
Cases: {cases_prisons} (+{cases_prisons_diff})
Deaths: {deaths_prisons} (+{deaths_prisons_diff})

Halfway Houses
Cases: {cases_halfway} (+{cases_halfway_diff})
Deaths: {deaths_halfway} (+{deaths_halfway_diff})

Employee Cases: {cases_employees} (+{cases_employees_diff})

Data: {DATA_URL}

#COVID19 #NJ"

  mdd =
    max(locations_data$as_of) %>%
    format("%m/%d", tz = "EST") %>%
    substr(2, nchar(.))

  # Because which.m** return only the first value
  locs_new = locations_data[locations_data$as_of == max(locations_data$as_of), ]
  locs_old = locations_data[locations_data$as_of == min(locations_data$as_of), ]
  prisons_new = locs_new[locs_new$system == "PRISONS AND ANCILLARY LOCATIONS", ]
  prisons_old = locs_old[locs_old$system == "PRISONS AND ANCILLARY LOCATIONS", ]
  halfway_new = locs_new[
    locs_new$system == "RESIDENTIAL COMMUNITY RELEASE PROGRAM", ]
  halfway_old = locs_old[
    locs_old$system == "RESIDENTIAL COMMUNITY RELEASE PROGRAM", ]

  cases_prisons   = prisons_new$inmates
  deaths_prisons  = prisons_new$inmate_deaths
  cases_halfway   = halfway_new$inmates
  deaths_halfway  = halfway_new$inmate_deaths
  # Employee cases only reported for prisons/offices, as halfway houses are
  # staffed by non-DOC employees
  cases_employees = prisons_new$employees

  cases_prisons_diff   = cases_prisons - prisons_old$inmates
  deaths_prisons_diff  = deaths_prisons - prisons_old$inmate_deaths
  cases_halfway_diff   = cases_halfway - halfway_old$inmates
  deaths_halfway_diff  = deaths_halfway - halfway_old$inmate_deaths
  cases_employees_diff = cases_employees - prisons_old$employees

  return(glue(TWEET_PLAN))

}
