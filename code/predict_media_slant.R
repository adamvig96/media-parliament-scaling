###########################################################################################

# Predict slant for media outlets with previously trained wordscore model

###########################################################################################


rm(list=ls())
renv::activate()

library(dplyr)
library(ggplot2)
library(quanteda)
quanteda_options(threads = 8)
require(quanteda.textmodels)
library(tidyverse)

## proposed model: 

tmod_ws <-  read_rds("data/output/wordscore_fit.rds")
selected_phrases <- read_rds("data/output/selected_parl_phrases.rds")
corpus <- read_rds("data/output/media_2019_2021_corpus.rds")

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
                tokens_tolower() %>%
                tokens_wordstem(language = 'hu') %>%
                tokens_ngrams(n = 2:3) %>%
                tokens_select(pattern = selected_phrases, selection = "keep") 

rm(corpus)

phrase_frequency_table_media <- dfm(media_tokens) %>% dfm_group(groups = site_month)

# predict slant

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)

predicted_slant <- as.data.frame(pred_ws) 
predicted_slant <- cbind(site_month = rownames(predicted_slant), predicted_slant)
rownames(predicted_slant) <- 1:nrow(predicted_slant)

predicted_slant %>% write_csv("data/output/monthly_slant_pred.csv")
