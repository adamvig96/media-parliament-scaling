renv::activate()

library(dplyr)
library(ggplot2)
library(quanteda)
quanteda_options(threads = 8)
require(quanteda.textmodels)
library(tidyverse)

# Proposed model
tmod_ws <- read_rds("data/intermed/wordscore_fit.rds")
selected_phrases <- read_rds("data/intermed/selected_phrases.rds")

# Functions
read_raw <- function(portal) {
  df <- read_csv(paste("data/raw/media-corpus/", portal, sep = "")) %>%
    mutate(ym = substr(date, 1, 7)) %>%
    mutate(year = as.factor(substr(ym, 1, 4))) %>%
    mutate(ym = as.Date(paste(ym, "-01", sep = ""))) %>%
    mutate(quarter = lubridate::quarter(ym, with_year = F)) %>%
    mutate(date_original = date) %>%
    mutate(date = zoo::as.yearqtr(paste(year, quarter, sep = "-"))) %>%
    mutate(site_quarter = paste(page, date, sep = "_"))

  return(df)
}

create_corpus <- function(media_df) {
  corpus <- corpus(media_df$content)
  docvars(corpus, "page") <- media_df$page
  docvars(corpus, "site_quarter") <- media_df$site_quarter

  return(corpus)
}

tokenize_corpus <- function(media_coprus, selected_phrases = selected_phrases) {
  media_tokens <- tokens(media_coprus,
    remove_punct = T,
    remove_symbols = T,
    remove_numbers = T,
    remove_separators = T
  ) %>%
    tokens_tolower() %>%
    tokens_wordstem(language = "hu") %>%
    tokens_ngrams(n = 2) %>%
    tokens_select(pattern = selected_phrases, selection = "keep")

  return(media_tokens)
}

create_dfm <- function(media_tokens) {
  return(
    dfm(media_tokens) %>%
      dfm_group(groups = site_quarter)
  )
}

predict_media_slant <- function(media_dfm, model_fit = model_fit) {
  pred <- predict(model_fit, se.fit = TRUE, newdata = media_dfm)

  pred <- as.data.frame(pred)
  pred <- cbind(site_quarter = rownames(pred), pred)
  rownames(pred) <- 1:nrow(pred)
  pred$site <- stringr::str_split_fixed(pred$site_quarter, "_", 2)[, 1]
  pred$date <- stringr::str_split_fixed(pred$site_quarter, "_", 2)[, 2]
  pred <- pred %>%
    select(c("site", "date", "fit", "se.fit"))

  return(pred)
}

estimate_slant <- function(raw_file) {
  read_raw(raw_file) %>%
    create_corpus() %>%
    tokenize_corpus(selected_phrases = selected_phrases) %>%
    create_dfm() %>%
    predict_media_slant(model_fit = tmod_ws) %>%
    write_csv(paste("data/slant_estimates/", raw_file, sep = ""))
}