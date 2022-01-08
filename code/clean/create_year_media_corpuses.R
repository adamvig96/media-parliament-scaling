renv::activate()
rm(list=ls())

library(dplyr)
library(tidyverse)
library(quanteda)

# Read raw
media_corpus <- read_csv("data/raw/media_corpus_raw.csv") %>% 
  mutate(ym = substr(date, 1, 7 )) %>% 
  mutate(site_month = paste(page, ym, sep="_")) %>% 
  mutate(year = as.integer(substr(date, 1, 4)))

# Create year sample corpuses

for (year_index in 2010:2021){
  year_sample <- media_corpus %>% filter(year == year_index)
  corpus <- corpus(year_sample$content)
  docvars(corpus, "page") <- year_sample$page
  docvars(corpus, "site_month") <- year_sample$site_month
  write_rds(corpus,
            paste("data/media_corpus/media_corpus_", as.character(year_index), ".rds",
                  sep = ""))
}
