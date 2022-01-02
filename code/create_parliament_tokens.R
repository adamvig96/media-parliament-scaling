renv::activate()
rm(list=ls())

library(dplyr)
library(quanteda)
library(tidyverse)
library(gofastr)

parl_text <- read_csv("data/input/parlament_speech_2010-2014.csv")  %>% 
  filter(type == "vezérszónoki felszólalás" 
         | type == "felszólalás" 
         | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" 
         | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" 
         | type == "kérdés megválaszolva" 
         | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" 
         | type == "napirend előtti felszólalás"
         | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" 
         | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" 
         | type == "interpelláció szóban megválaszolva") %>%
  dplyr::rename(text = text_strip) %>% 
  drop_na() %>% 
  mutate (name = str_replace_all(speaker,"Dr. ",""),
          oldal = ifelse(speaker_party == "Fidesz" | speaker_party == "KDNP", "Fidesz-KDNP", "Ellenzék"),
          label = ifelse(oldal == "Fidesz-KDNP", 1, 0),
          month = substr(date,6,7),
          date = as.Date(date, format = '%Y.%m.%d.'))

# drop jobbik here
parl_text <- parl_text %>% filter(speaker_party != "Jobbik")

corpus <- corpus(parl_text %>% select(text))
docvars(corpus, "speaker_party") <- parl_text$speaker_party
docvars(corpus, "speaker") <- parl_text$speaker
docvars(corpus, "side") <- parl_text$oldal
docvars(corpus, "label") <- parl_text$label
docvars(corpus, "date") <- parl_text$date

rm(parl_text)

swords <- append(
  scan("data/stopwords/stopwords-hu.txt", what="", sep="\n"),
  scan("data/stopwords/stopwords-parliament.txt", what="", sep="\t")
  ) %>% 
  prep_stopwords()

sphrases <- scan("data/stopwords/stopphrases-parliament.txt", what="", sep="\t") %>% 
  prep_stopwords()

speaker_names <- read_csv("data/input/representative_names_2014-2018.csv")$Név %>%
  tolower() %>% 
  prep_stopwords()

parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
               tokens_tolower() %>% 
               tokens_select(pattern = phrase(sphrases), selection = "remove") %>% 
               tokens_select(pattern = phrase(speaker_names), selection = "remove") %>% 
               tokens_select(pattern = swords, selection = "remove") %>% 
               tokens_wordstem(language = 'hu')

parl_tokens %>% write_rds("data/output/parliament_tokens.rds")
