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

# bigramm

bigram_keyness <- tokens_ngrams(parl_tokens, n = 2) %>% 
  dfm() %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 20) %>% 
  textstat_keyness(target = 1, measure = "chi2")

# trigramm

trigram_keyness <- tokens_ngrams(parl_tokens, n = 3) %>% 
  dfm() %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 5) %>%
  textstat_keyness(target = 1, measure = "chi2")


# Create final n=2000 phrase list

bigrams <- bigram_keyness %>% mutate(feature = str_replace_all(feature, "_", " "))
trigrams <- trigram_keyness %>% mutate(feature = str_replace_all(feature, "_", " "))

bigrams <- rbind(head(bigrams, 500), tail(bigrams, 500))
trigrams <- rbind(head(trigrams, 500), tail(trigrams, 500))

p <- data.frame(cbind(c(bigrams$feature, trigrams$feature)))
colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p, " ", "_")
selected_ps <- prep_stopwords(p %>% select(p))

selected_ps %>% write_rds("data/intermed/selected_phrases.rds")


features_table <- cbind(bigrams, trigrams)
features_table <- cbind(head(features_table, 60), tail(features_table, 60))

features_table %>% write_xlsx("data/intermed/top_khi_phrases_raw.xlsx")





