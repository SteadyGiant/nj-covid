NJ COVID-19 Data

Right now, I'm tracking [confirmed cases and deaths](https://njdoc.gov/pages/COVID19Updates.shtml)
in prisons and halfway houses, published every weeknight by the NJ Dept of
Corrections.

## Data

**`data/DOC/Summary`** contains a "Summary" data spreadsheet:

* `as_of` - date on which website was updated

* `tested` - Inmates tested

* `positive` - Inmates testing positive

* `negative` - Inmates testing negative (for now?)

* `pending` - Inmates with pending tests

Each row represents a day for which data was reported, starting on 2020-04-17.
(I must not have noticed this data was reported until then.)

**`data/DOC`** contains a "Locations" spreadsheet for each day:

* `as_of` - date and time at which website was updated

* `system` - "PRISONS AND ANCILLARY LOCATIONS" = DOC prisons and offices;
  "RESIDENTIAL COMMUNITY RELEASE PROGRAM" = Halfway houses staffed by non-DOC
  staff

* `location` - A prison, DOC office, or halfway house

* `employees` - DOC employees testing positive

* `inmates` - Prison or halfway house inmates testing positive

* `inmate deaths` - Confirmed deaths among prison or halfway house inmates. Not
  reported until 2020-04-09; the first death occurred sometime before then and
  after 2020-04-07.

## Code

* **`code/DOC_scrape.R`** scrapes the data from [here](https://njdoc.gov/pages/COVID19Updates.shtml)

* **`code/one-off/`** contains "one-off" scripts executed once to make some ad
  hoc changes to the data
