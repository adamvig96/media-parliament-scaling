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
library(gofastr)

<<<<<<< HEAD
## proposed model: 

tmod_ws <-  read_rds("data/output/wordscore_fit_1418_wojobbik.rds")
selected_phrases <- read_rds("data/output/selected_parl_phrases_1418_wojobbik.rds")
corpus <- read_rds("data/media_2019_2021_corpus.rds")
=======
tmod_ws <-  read_rds("data/output/wordscore_fit_1820_pred_speaker_smmoth.rds")
selected_phrases <- read_rds("data/output/selected_parl_phrases_1820.rds")


# with unigram model
tmod_ws <-  read_rds("data/output/wordscore_fit_1920_wuni.rds")
selected_phrases <- read_rds("data/output/selected_parl_phrases_1920_wuni.rds")


# with 18-20 unigram model
tmod_ws <-  read_rds("data/output/wordscore_fit_1820_wuni.rds")
selected_phrases <- read_rds("data/output/selected_parl_phrases_1820_wuni.rds")


# with 18-20 only unigram model
tmod_ws <-  read_rds("data/output/wordscore_fit_1820_unionly.rds")
selected_phrases <- read_csv("data/output/unigramms.csv") %>% select(feature) %>% 
                    prep_stopwords()

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
table(df_media$page)
df_media <- df_media %>% mutate(site_month = paste(page,as.character(month),sep="_"))

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

rm(df_media)

#read selected phrases
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
                tokens_tolower() %>%
                tokens_wordstem(language = 'hu') %>%
<<<<<<< HEAD
                tokens_ngrams(n = 2:3) %>%
                tokens_select(pattern = selected_phrases, selection = "keep") 

rm(corpus)
=======
                tokens_ngrams(n = 2:3) %>% # !!!!!!!!!!!!!!!!!
                tokens_select(pattern = selected_phrases, selection = "keep")

rm(corpus)

phrase_frequency_table_media <- dfm(media_tokens, groups = "site_month")

#now predict slant

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)


df <- as.data.frame(pred_ws) 
df <- cbind(site_month = rownames(df), df)
rownames(df) <- 1:nrow(df)

#df["site_month"] <- phrase_frequency_table_media %>% dplyr::select(doc_id)

df %>% write_csv("data/output/monthly_pred_1820_predspeech.csv")
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

phrase_frequency_table_media <- dfm(media_tokens) %>% dfm_group(groups = site_month)

<<<<<<< HEAD
# predict slant
=======
### ADD 2021

# add 2021 media corpus

df_media <- read_csv("data/input/2021_mno24indextelexorigo_belfold.csv")

df_media <- df_media %>% mutate(site_month = paste(page,as.character(month),sep="_"))

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

rm(df_media)
rm(media_tokens)


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
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)

predicted_slant <- as.data.frame(pred_ws) 
predicted_slant <- cbind(site_month = rownames(predicted_slant), predicted_slant)
rownames(predicted_slant) <- 1:nrow(predicted_slant)

<<<<<<< HEAD
predicted_slant %>% write_csv("data/output/monthly_pred_1418_wojobbik.csv")
=======
df <- as.data.frame(pred_ws) 
df <- cbind(site_month = rownames(df), df)
rownames(df) <- 1:nrow(df)


df %>% write_csv("data/output/monthly_pred_1820_2021_predspeech.csv")


# ADD 2019
rm(list=ls())


df_media <- read_csv("data/input/newspaper_text_2019.csv")


corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("site")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

rm(df_media)

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_wordstem(language = 'hu') %>%
  tokens_ngrams(n=2:3) %>%  # !!!!!
  tokens_select(pattern = selected_phrases, selection = "keep")


phrase_frequency_table_media <- dfm(media_tokens, groups = "site_month")

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)

df <- as.data.frame(pred_ws) 
df <- cbind(site_month = rownames(df), df)
rownames(df) <- 1:nrow(df)

df %>% write_csv("data/output/monthly_pred_1820_2019_predspeech.csv")



>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad
