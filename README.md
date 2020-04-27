NJ COVID-19 Data

Right now, I'm tracking [confirmed cases and deaths](https://njdoc.gov/pages/COVID19Updates.shtml)
in prisons and halfway houses, published every weeknight by the NJ Dept of
Corrections.

## Data

NOTE: According to [the president of the state corrections officers union](https://www.northjersey.com/story/news/coronavirus/2020/04/24/coronavirus-push-testing-nj-prisons-grows-deaths-mount/3019641001/),
as of 2020-04-24 the DOC has reportedly tested "only inmates whose symptoms have
gotten so severe they need to be hospitalized[.]" So the number of cases
reported are almost certainly severe underestimates of the true number of cases.

Also, according to the same article, 2 DOC corrections officers are reported to 
have died, as of 2020-04-24. Employee deaths are not reported by the DOC, at
least not on the "COVID-19 Updates" website linked above.

### Testing Data

**`data/DOC/Summary`** contains a "Summary" data spreadsheet:

* `as_of` - date on which website was updated

* `tested` - Inmates tested

* `positive` - Inmates testing positive

* `negative` - Inmates testing negative (for now?)

* `pending` - Inmates with pending tests

Each row represents a day for which data was reported, starting on 2020-04-17.
(I must not have noticed this data was reported until then.)

### Cases/Deaths by Location Data

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

* **`code/one-off`** contains "one-off" scripts executed once to make some ad
  hoc changes to the data
