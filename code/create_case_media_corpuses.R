renv::activate()
rm(list=ls())

library(dplyr)
library(tidyverse)
library(quanteda)

# Read raw
media_corpus <- read_csv("data/raw/media_corpus_raw.csv") %>% 
  mutate(ym = substr(date, 1, 7 )) %>% 
  mutate(site_month = paste(page, ym, sep="_"))

# Create case study corpuses
index_corpus <- media_corpus %>% filter(date >= "2019-01-01")
corpus <- corpus(index_corpus$content)
docvars(corpus, "page") <- index_corpus$page
docvars(corpus, "site_month") <- index_corpus$site_month
write_rds(corpus, "data/output/index_case_corpus.rds")

origo_corpus <- media_corpus %>% filter(date >= "2014-01-01") %>% 
  filter(date < "2018-01-01")
corpus <- corpus(origo_corpus$content)
docvars(corpus, "page") <- origo_corpus$page
docvars(corpus, "site_month") <- origo_corpus$site_month
write_rds(corpus, "data/output/origo_case_corpus.rds")

mno_corpus <- media_corpus %>% filter(date >= "2013-01-01") %>% 
  filter(date < "2017-01-01")
corpus <- corpus(mno_corpus$content)
docvars(corpus, "page") <- mno_corpus$page
docvars(corpus, "site_month") <- mno_corpus$site_month
write_rds(corpus, "data/output/mno_case_corpus.rds")

