renv::activate()
rm(list = ls())

library(dplyr)
library(ggplot2)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textstats)
library(tidyverse)
library(gofastr)

parl_tokens <- read_rds("data/intermed/parliament_tokens.rds")

bigram_keyness <- tokens_ngrams(parl_tokens, n = 2) %>%
  dfm() %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 100) %>%
  textstat_keyness(target = 1, measure = "chi2")

# Create final n=1000 phrase list

bigrams <- bigram_keyness %>%
  mutate(feature = str_replace_all(feature, "_", " "))

bigrams <- rbind(head(bigrams, 500), tail(bigrams, 500))

p <- data.frame(bigrams$feature)
colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p, " ", "_")
selected_ps <- prep_stopwords(p %>% select(p))

selected_ps %>% write_rds("data/intermed/selected_phrases.rds")