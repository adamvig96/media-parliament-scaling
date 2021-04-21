rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(tidytext)
library(gofastr)


setwd("/Users/vigadam/Dropbox/github/media_network/media_data/parliament_speech_text/")

bigrams <- read_csv("data/bigramms_stem.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/trigramms_stem.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))

corpus <- corpus(bigrams$feature)

#dict_bigrams <- dictionary(list(bigrams = bigrams$feature))
dict_trigrams <- dictionary(list(trigrams = trigrams$feature))

dfm <- dfm(corpus)

dfm_trigram_mention <-dfm_select(dfm, pattern = phrase(dict_trigrams), selection = "remove")

df = dfm_trigram_mention %>% convert(to = "data.frame")

df$sum <- rowSums(df[2:515])

df <- df %>% filter(sum == 2)

df <- df %>% mutate(doc_id = str_remove_all(doc_id,"text"))

bigrams$doc_id <- seq(1,dim(bigrams)[1],by=1)


bigrams <- merge(x=df %>% select(doc_id),y=bigrams,all.x=TRUE,by="doc_id")

bigrams %>% write_csv("data/bigrams_stem_clean.csv")


p <- data.frame(cbind(c(bigrams$feature,trigrams$feature)))
colnames(p)[1] <- "p"

p %>% write_csv("data/p_stem.csv")



