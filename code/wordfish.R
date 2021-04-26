rm(list=ls())

library(dplyr)
library(ggplot2)
library(tidyverse)
library(gofastr)
require(quanteda)
require(quanteda.textmodels)
require(quanteda.textplots)


df_media <- read_csv("data/input/newspaper_text_2020.csv")

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

df_media <- df_media %>% filter(category == "belfold") %>% drop_na(text)

# write this filtered text file list to rds, because this will be used in other models too
df_media %>% write_rds("data/output/media_belfold.rds")


df_media <- df_media %>% mutate(month_i = strtoi(month))

df_media <- df_media %>% mutate(page2 = ifelse((month_i<8)&(page == "Index"),"index_pre",page))


corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")
docvars(corpus, "page2") <- df_media %>% select("page2")

rm(df_media)
swords <- prep_stopwords(scan("data/input/stopwords-hu.txt", what="", sep="\n"))

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_select(pattern = swords, selection = "remove") %>% 
  tokens_wordstem(language = 'hu') 

rm(corpus)

media_tokens %>% write_rds("data/output/media_tokens_wordfish.rds")

media_tokens <- read_rds("data/output/media_tokens_wordfish.rds")


phrase_frequency_table_media <- dfm(media_tokens,groups = "page") %>% 
  dfm_trim(min_termfreq = 300,termfreq_type = 'count')

tmod_wf <- textmodel_wordfish(phrase_frequency_table_media, dir = c(6, 1))

summary(tmod_wf)


wordfish_plot <- textplot_scale1d(tmod_wf)


jpeg("figures/wordfish2.png",width = 392, height = 314)
wordfish_plot
dev.off()



