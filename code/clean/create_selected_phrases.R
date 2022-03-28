renv::activate()
rm(list = ls())

library(dplyr)
library(ggplot2)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(tidyverse)
library(gofastr)
library(writexl)

parl_tokens <- read_rds("data/intermed/parliament_tokens.rds")

# DTM
dtm_df <- parl_tokens %>%
  tokens_ngrams(n = 2:3) %>%
  dfm() %>%
  dfm_trim(min_termfreq = 60)

dtm_df <- as.data.frame(dtm_df)

p <- data.frame(names(dtm_df))
colnames(p)[1] <- "p"
p <- p %>% filter(p != "doc_id")
selected_ps <- prep_stopwords(p %>% select(p))

selected_ps %>% write_rds("data/intermed/selected_top_phrases.rds")