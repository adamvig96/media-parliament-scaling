rm(list=ls())

library(dplyr)
library(ggplot2)
library(tidyverse)
library(gofastr)
require(quanteda)
require(quanteda.textmodels)
require(quanteda.textplots)

##############################################################################
#       You can read the trained wordscore model below..

df_parl <- read_csv("data/input/parlament_speech_2020.csv") %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>% dplyr::rename(text = text_strip) %>% 
  drop_na() %>% mutate (name = str_replace_all(speaker,"Dr. ",""))

# merge all speeches of the representatives
df_parl <- df_parl %>% group_by(name) %>% summarise(speaker_party = unique(speaker_party),
                                           side = unique(oldal),
                                           text = paste(text, collapse=" "))

# read observed ideology of representatives (this is created in GS-model.ipynb)
obs_y <- read_csv("data/output/yc.csv")

df_parl <- merge(x = df_parl,y = obs_y %>% select(name,ideology), by = "name", all.x = TRUE)

corpus <- corpus(df_parl %>% select(text))
docvars(corpus, "speaker_party") <- df_parl %>% select("speaker_party")
docvars(corpus, "name") <- df_parl %>% select("name")
docvars(corpus, "ideology") <- df_parl %>% select("ideology")

parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_wordstem(language = 'hu') %>%
  tokens_ngrams(n=2:3) 

p <- read_csv("data/output/p.csv")

selected_ps = prep_stopwords(p %>% select(p))

phrase_frequency_table_parliament <- dfm(parl_tokens, groups = "name") %>%
  dfm_select(pattern = phrase(selected_ps), selection = "keep")

# train wordscore model
tmod_ws <- textmodel_wordscores(phrase_frequency_table_parliament, 
                                y = corpus$ideology, smooth = 1)

tmod_ws %>% write_rds("data/output/wordscore_fit.rds")

summary(tmod_ws)

####################################################################################
#     Read trained wordscore model

rm(list=ls())

tmod_ws <- read_rds("data/output/wordscore_fit.rds")
media_tokens <- read_rds("data/output/media_tokens.rds")
p <- read_csv("data/output/p.csv")
selected_ps = prep_stopwords(p %>% select(p))


# create phrase frequencies of previously selected phrases in media outlets' corpus

phrase_frequency_table_media <- dfm(media_tokens,groups = "page") %>% 
  dfm_select(pattern = phrase(selected_ps), selection = "keep")

rm(media_tokens)

pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = phrase_frequency_table_media)

textplot_scale1d(pred_ws)




