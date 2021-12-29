renv::activate()
rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(tidyverse)
library(gofastr)

parl_tokens <- read_rds("data/output/parliament_tokens.rds")

# bigramm 
toks_2gram <- tokens_ngrams(parl_tokens, n = 2)

bi_dtm <- dfm(toks_2gram) %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 20) 

bigram_keyness <- bi_dtm %>% textstat_keyness(target=1, measure="chi2")

textplot_wordcloud(dfm_group(bi_dtm, groups = side), comparison = TRUE, max_words = 100)

# trigramm 

toks_3gram <- tokens_ngrams(parl_tokens, n = 3)

dtm_3gram <- dfm(toks_3gram) %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 20) 

trigram_keyness <- dtm_3gram %>% textstat_keyness(target=1,measure="chi2") 

wordplot <- textplot_keyness(trigram_keyness,n=30,min_count = 5,margin=0.15)

textplot_keyness(trigram_keyness)

# create wordcloud comparison
dfm_group(dtm_3gram, groups = side) %>% 
  textplot_wordcloud(comparison = TRUE, max_words = 100)


# Create final n=2000 phrase list

bigrams <- bigram_keyness %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- trigram_keyness %>% mutate(feature = str_replace_all(feature,"_"," "))

bigrams <-  rbind(head(bigrams, 500), tail(bigrams, 500))
trigrams <-  rbind(head(trigrams, 500), tail(trigrams, 500))

p <- data.frame(cbind(c(bigrams$feature,trigrams$feature)))
colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p," ","_") 
selected_ps <-prep_stopwords(p %>% select(p))

selected_ps %>% write_rds("data/output/selected_parl_phrases.rds")