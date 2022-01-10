renv::activate()
rm(list = ls())

library(dplyr)
library(quanteda)
library(quanteda.textmodels)
quanteda_options(threads = 8)
library(tidyverse)

parl_tokens <- read_rds("data/intermed/parliament_tokens.rds")
selected_ps <- read_rds("data/intermed/selected_phrases.rds")
tmod_ws <- read_rds("data/intermed/wordscore_fit.rds")

# Create phrase frequencies of selected phrases in parliament text

phrase_frequency_table_parliament <- parl_tokens %>%
  tokens_ngrams(n = 2:3) %>%
  tokens_select(pattern = phrase(selected_ps), selection = "keep") %>%
  dfm() %>%
  dfm_group(groups = side_quarter)

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_parliament)

predicted_slant <- as.data.frame(pred_ws)
predicted_slant <- cbind(party_quarter = rownames(predicted_slant), predicted_slant)
rownames(predicted_slant) <- 1:nrow(predicted_slant)

predicted_slant %>% write_csv("data/slant_estimates/party_slant_pred.csv")