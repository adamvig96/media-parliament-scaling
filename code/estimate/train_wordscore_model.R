renv::activate()
rm(list=ls())

library(dplyr)
library(quanteda)
library(quanteda.textmodels)
quanteda_options(threads = 8)
library(tidyverse)

parl_tokens <- read_rds("data/intermed/parliament_tokens.rds")
selected_ps <- read_rds("data/intermed/selected_phrases.rds")

# Create phrase frequencies of selected phrases in parliament text

phrase_frequency_table_parliament <- parl_tokens %>%
  tokens_ngrams(n=2:3) %>%
  tokens_select(pattern = phrase(selected_ps), selection = "keep") %>% 
  dfm()

# train wordscore model
tmod_ws <- textmodel_wordscores(phrase_frequency_table_parliament, 
                                y = phrase_frequency_table_parliament$label,
                                smooth = 0)

tmod_ws %>% write_rds("data/intermed/wordscore_fit.rds")

# predict for parliament speakers

#pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_parliament)
#
#predicted_slant <- as.data.frame(pred_ws) 
#
#parl_text_meta <- read_csv("data/intermed/parl_text_metadata.csv")
#
#parl_text_meta <- cbind(parl_text_meta,predicted_slant)
#
#party_slant <- parl_text_meta %>% mutate(ym = substr(date, 1, 7 )) %>% 
#  group_by(speaker_party, ym) %>% 
#  summarise(slant = mean(fit),
#            se = sd(fit, na.rm=T) / sqrt(n())
#  )
#
#party_slant %>% write_csv("data/slant_estimates/party_slant_pred.csv")
#
#
#site_slant <- parl_text_meta %>% mutate(ym = substr(date, 1, 7 )) %>% 
#  group_by(govt_opp, ym) %>% 
#  summarise(slant = mean(fit),
#            se = sd(fit, na.rm=T) / sqrt(n())
#  )
#
#site_slant %>% write_csv("data/slant_estimates/govt_opp_slant_pred.csv")




