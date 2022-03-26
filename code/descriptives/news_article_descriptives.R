renv::activate()
rm(list = ls())

library(dplyr)
library(tidyverse)

newsarticle_metadata <- read_csv("data/intermed/news_article_metadata.csv")

newsarticle_metadata %>% group_by(page) %>%
  summarise(n_articles = n())
