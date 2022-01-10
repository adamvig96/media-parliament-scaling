renv::activate()
rm(list = ls())

library(dplyr)
library(ggplot2)
library(quanteda)
quanteda_options(threads = 8)
require(quanteda.textmodels)
library(tidyverse)

## proposed model:

tmod_ws <- read_rds("data/intermed/wordscore_fit.rds")
selected_phrases <- read_rds("data/intermed/selected_phrases.rds")

for (year_index in 2010:2021) {
  corpus <- read_rds(
    paste("data/media_corpus/media_corpus_", as.character(year_index), ".rds",
      sep = ""
    )
  )

  media_tokens <- tokens(corpus,
    remove_punct = T,
    remove_symbols = T,
    remove_numbers = T,
    remove_separators = T
  ) %>%
    tokens_tolower() %>%
    tokens_wordstem(language = "hu") %>%
    tokens_ngrams(n = 2:3) %>%
    tokens_select(pattern = selected_phrases, selection = "keep")

  rm(corpus)

  phrase_frequency_table_media <- dfm(media_tokens) %>%
    dfm_group(groups = site_quarter)

  # predict slant

  pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)

  predicted_slant <- as.data.frame(pred_ws)
  predicted_slant <- cbind(site_quarter = rownames(predicted_slant), predicted_slant)
  rownames(predicted_slant) <- 1:nrow(predicted_slant)

  predicted_slant %>% write_csv(
    paste("data/slant_estimates/Q_slant_pred_", as.character(year_index), ".csv", sep = "")
  )
}