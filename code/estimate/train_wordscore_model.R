renv::activate()
rm(list = ls())

library(dplyr)
library(quanteda)
library(quanteda.textmodels)
quanteda_options(threads = 8)
library(tidyverse)

parl_tokens <- read_rds("data/intermed/parliament_tokens.rds")
selected_ps <- read_rds("data/intermed/selected_phrases.rds")

# Create phrase frequencies of selected phrases in parliament text

phrase_frequency_table_parliament <- parl_tokens %>%
  tokens_ngrams(n = 2:3) %>%
  tokens_select(pattern = phrase(selected_ps), selection = "keep") %>%
  dfm()

# train wordscore model
tmod_ws <- textmodel_wordscores(phrase_frequency_table_parliament,
  y = phrase_frequency_table_parliament$label,
  smooth = 0
)

tmod_ws %>% write_rds("data/intermed/wordscore_fit.rds")