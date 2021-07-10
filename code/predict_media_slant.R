

rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(gofastr)


## create belfold text in 2020
df_media <- read_csv("data/input/newspaper_text_2020.csv")

df_media$category <- tolower(df_media$category)

df_media$page <- df_media$page %>% replace_na("telex")

df_media <- df_media %>% 
  mutate(category = gsub("á", "a", category)) %>% 
  mutate(category = gsub("ö", "o", category)) %>%
  mutate(category = gsub("ü", "u", category))  %>%
  mutate(category = gsub("é", "e", category))  %>%
  mutate(category = gsub("fn", "gazdasag", category)) %>% # fn is gazdasag in 24.hu
  mutate(category = gsub("egeszsegugy", "egeszseg", category)) %>%
  mutate(category = gsub("belföld", "belfold", category)) %>%
  mutate(category = gsub("itthon", "belfold", category)) %>% #origo
  mutate(category = gsub("nagyvilag", "kulfold", category)) %>% #origo
  mutate(category = gsub("politika", "belfold", category)) %>% # politika is local politics at 444
  mutate(category = gsub("ketharmad", "belfold", category)) %>% # 888
  mutate(category = gsub("amerika-london-parizs", "kulfold", category))  # 888

df_media <- df_media %>% filter(category == "belfold") %>% drop_na(text)

df_media <- df_media %>% mutate(site_month = paste(page,as.character(month),sep="_"))

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

rm(df_media)

#read selected phrases
selected_phrases <- read_csv("data/output/p_1920.csv")$p %>% prep_stopwords() %>% phrase()


media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
                tokens_tolower() %>%
                tokens_wordstem(language = 'hu') %>%
                tokens_ngrams(n = 2:3) %>%
                tokens_select(pattern = selected_phrases, selection = "keep")

phrase_frequency_table_media <- dfm(media_tokens, groups = "site_month")

#now predict slant
tmod_ws <-  read_rds("data/output/wordscore_fit_1920.rds")

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)


df <- as.data.frame(pred_ws) 
df <- cbind(site_month = rownames(df), df)
rownames(df) <- 1:nrow(df)

#df["site_month"] <- phrase_frequency_table_media %>% dplyr::select(doc_id)

df %>% write_csv("data/output/monthly_pred_1920_v2.csv")


### ADD 2021

# add 2021 media corpus

df_media <- read_csv("data/input/2021_mno24indextelexorigo_belfold.csv")

df_media <- df_media %>% mutate(site_month = paste(page,as.character(month),sep="_"))

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

rm(df_media)

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
                tokens_tolower() %>%
                tokens_wordstem(language = 'hu') %>%
                tokens_ngrams(n=2:3) %>% 
                tokens_select(pattern = selected_phrases, selection = "keep")

phrase_frequency_table_media <- dfm(media_tokens, groups = "site_month")


pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)


df <- as.data.frame(pred_ws) 
df <- cbind(site_month = rownames(df), df)
rownames(df) <- 1:nrow(df)


df %>% write_csv("data/output/monthly_pred_1920_2021_v2.csv")

