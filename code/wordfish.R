rm(list=ls())

library(dplyr)
library(ggplot2)
library(tidyverse)
library(gofastr)
require(quanteda)
require(quanteda.textmodels)
require(quanteda.textplots)

#read filtered text media data or read tokenized wordfish data below

df_media <-  read_rds("data/output/media_belfold.rds")

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")

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

#  You can read tokenized file for wordfish model here

media_tokens <- read_rds("data/output/media_tokens_wordfish.rds")


phrase_frequency_table_media <- dfm(media_tokens,groups = "page") %>% 
  dfm_trim(min_termfreq = 300,termfreq_type = 'count')

tmod_wf <- textmodel_wordfish(phrase_frequency_table_media, dir = c(6, 1))

summary(tmod_wf)


wordfish_plot <- textplot_scale1d(tmod_wf)


jpeg("figures/wordfish.png",width = 392, height = 314)
wordfish_plot
dev.off()


##########################################################################
# parlament speech

parl_tokens <- read_rds("data/output/parl_tokens.rds")

#stemming
parl_tokens <- parl_tokens %>% tokens_wordstem(language = 'hu')

phrase_frequency_table_parl <- dfm(parl_tokens,groups = "speaker_party") %>% 
  dfm_trim(min_termfreq = 300,termfreq_type = 'count')

tmod_wf <- textmodel_wordfish(phrase_frequency_table_parl, dir = c(2, 1))

summary(tmod_wf)

wordfish_plot <- textplot_scale1d(tmod_wf)


jpeg("figures/wordfish_party.png",width = 392, height = 314)
wordfish_plot
dev.off()

