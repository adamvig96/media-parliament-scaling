rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(tidytext)
library(gofastr)

setwd("/Users/vigadam/Dropbox/github/media_network/media_data/parliament_speech_text/")

p <- read_csv("data/p_stem.csv")
p$p <- str_replace_all(p$p," ","_") 


df_text <- read_csv("data/parldata_2020.csv")  %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>% dplyr::rename(text = text_strip) %>% 
  drop_na() %>% mutate (name = str_replace_all(speaker,"Dr. ",""))





corpus <- corpus(df_text %>% select(text))
docvars(corpus, "speaker_party") <- df_text %>% select("speaker_party")
docvars(corpus, "name") <- df_text %>% select("name")

parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
                      tokens_tolower() %>%
                      tokens_wordstem(language = 'hu') %>%
                      tokens_ngrams(n=2:3) 

fpc <- dfm(parl_tokens,groups = "name") %>% dfm_select(pattern = phrase(prep_stopwords(p %>% select(p))), selection = "keep")


fpc <- fpc %>% convert(to="data.frame") %>% write_csv("data/frequency_of_stemed_phrases.csv")



### media

df_media <- read_csv("/Users/vigadam/Dropbox/github/media_network/media_data/clean_text/2020/all_site_2020.csv")

df_media$category <- tolower(df_media$category)

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


table(df_media %>% filter(page == "Index") %>% select(category))

df_media <- df_media %>% filter(category == "belfold") %>% drop_na(text)

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")

media_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_wordstem(language = 'hu') %>%
  tokens_ngrams(n=2:3) 

rm(df_media)

fpc <- dfm(media_tokens,groups = "page") %>% dfm_select(pattern = phrase(prep_stopwords(p %>% select(p))), selection = "keep")


fpc <- fpc %>% convert(to="data.frame") %>% write_csv("data/frequency_of_stemed_media_phrases.csv")

