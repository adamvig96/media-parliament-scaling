renv::activate()
rm(list = ls())

library(dplyr)
library(tidyverse)
library(quanteda)

# Read raw
media_corpus <- read_csv("data/raw/media_corpus_raw.csv") %>%
  mutate(ym = substr(date, 1, 7)) %>%
  mutate(year = as.factor(substr(ym, 1, 4))) %>%
  mutate(ym = as.Date(paste(ym, "-01", sep = ""))) %>%
  mutate(quarter = lubridate::quarter(ym, with_year = F)) %>%
  mutate(date = zoo::as.yearqtr(paste(year, quarter, sep = "-"))) %>%
  mutate(site_quarter = paste(page, date, sep = "_"))

# Create year sample corpuses

for (year_index in 2010:2021) {
  year_sample <- media_corpus %>% filter(year == year_index)
  corpus <- corpus(year_sample$content)
  docvars(corpus, "page") <- year_sample$page
  docvars(corpus, "site_quarter") <- year_sample$site_quarter
  write_rds(
    corpus,
    paste("data/media_corpus/media_corpus_", as.character(year_index), ".rds",
      sep = ""
    )
  )
}