renv::activate()
rm(list = ls())

library(dplyr)
library(quanteda)
library(tidyverse)
library(gofastr)

parl_text <- read_csv("data/raw/parliament_speeches_2010-2020.csv") %>%
  filter(type == "vezérszónoki felszólalás" |
    type == "felszólalás" |
    type == "elhangzik az interpelláció/kérdés/azonnali kérdés" |
    type == "azonnali kérdésre adott képviselői viszonválasz" |
    type == "azonnali kérdésre adott képviselői viszonválasz" |
    type == "kétperces felszólalás" |
    type == "kérdés megválaszolva" |
    type == "napirend előttihez hozzászólás" |
    type == "napirend előtti felszólalás" |
    type == "napirend előtti felszólalás" |
    type == "azonnali kérdésre adott miniszteri viszonválasz" |
    type == "napirend utáni felszólalás" |
    type == "Előadói válasz" |
    type == "előterjesztő nyitóbeszéde" |
    type == "interpelláció szóban megválaszolva") %>%
  dplyr::rename(text = text_strip) %>%
  mutate(
    name = str_replace_all(speaker, "Dr. ", ""),
    govt_opp = ifelse(speaker_party %in% c("Fidesz", "KDNP"), "government",
      ifelse(speaker_party %in% c("MSZP", "LMP", "DK", "Jobbik", "Párbeszéd"), "opposition",
        NA
      )
    ),
    govt = ifelse(govt_opp == "government", 1, 0),
    ym = substr(date, 1, 7),
    year = substr(date, 1, 4),
    ym = as.Date(paste(ym, ".01", sep = ""), format = "%Y.%m.%d"),
    quarter = lubridate::quarter(ym, with_year = F),
    date_origin = date,
    date = zoo::as.yearqtr(paste(year, quarter, sep = "-")),
    govt_opp_quarter = paste(govt_opp, date, sep = "_"),
    speech_length = nchar(text),
  ) %>%
  drop_na(govt_opp, text)

# drop jobbik here
parl_text <- parl_text %>% filter(speaker_party != "Jobbik")

parl_text %>%
  select(-text) %>%
  write_csv("data/intermed/parl_text_metadata.csv")

corpus <- corpus(parl_text %>% select(text))
docvars(corpus, "speaker_party") <- parl_text$speaker_party
docvars(corpus, "speaker") <- parl_text$speaker
docvars(corpus, "side") <- parl_text$govt_opp
docvars(corpus, "side_quarter") <- parl_text$govt_opp_quarter
docvars(corpus, "label") <- parl_text$govt
docvars(corpus, "date") <- parl_text$date

rm(parl_text)

swords <- append(
  scan("data/stopwords/stopwords-hu.txt", what = "", sep = "\n"),
  scan("data/stopwords/stopwords-parliament.txt", what = "", sep = "\t")
) %>%
  prep_stopwords()

sphrases <- scan("data/stopwords/stopphrases-parliament.txt", what = "", sep = "\t") %>%
  prep_stopwords()

speaker_names <- rbind(
  read_csv("data/input/representative_names_2014-2018.csv"),
  read_csv("data/input/representative_names_2018-2020.csv")
)$Név %>%
  tolower() %>%
  prep_stopwords()

parl_tokens <- tokens(corpus,
  remove_punct = T,
  remove_symbols = T,
  remove_numbers = T,
  remove_separators = T
) %>%
  tokens_tolower() %>%
  tokens_select(pattern = phrase(sphrases), selection = "remove") %>%
  tokens_select(pattern = phrase(speaker_names), selection = "remove") %>%
  tokens_select(pattern = swords, selection = "remove") %>%
  tokens_wordstem(language = "hu")

parl_tokens %>% write_rds("data/intermed/parliament_tokens.rds")