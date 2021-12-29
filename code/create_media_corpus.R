###########################################################################################

# Predict slant for media outlets with previously trained wordscore model

###########################################################################################


rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
quanteda_options(threads = 8)
library(tidyverse)
library(gofastr)

## create belfold text in 2020
df_media <- read_csv("data/input/newspaper_text_2020.csv")

df_media$category <- tolower(df_media$category)

df_media$page <- df_media$page %>% replace_na("telex")

df_media %>% 
  group_by(date) %>% mutate(c = n()) %>% ungroup() %>% 
  ggplot(aes(x=as.Date(date),y=c)) + geom_line() + ylim(0,1000) +
  theme_bw()



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

df_media_2020 <- df_media %>% select(c("text","year","month","page"))
df_media_2019 <- read_csv("data/input/newspaper_text_2019.csv") %>% 
  rename("page" = "site" ) %>% select(c("text","year","month","page"))

df_media_2021 <- read_csv("data/input/newspaper_text_2021.csv") %>%
  select(c("text","year","month","page"))

df_media <- rbind(df_media_2019,df_media_2020,df_media_2021) %>% 
  mutate(site_month = paste(page,as.character(year),as.character(month),sep="_"))

rm(list=c("df_media_2019","df_media_2020","df_media_2021"))

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "site_month") <- df_media %>% select("site_month")

corpus %>% write_rds("data/media_2019_2021_corpus.rds")
