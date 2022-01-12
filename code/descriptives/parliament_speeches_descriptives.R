renv::activate()
rm(list = ls())

library(dplyr)
library(ggplot2)
library(scales)
library(tidyverse)
library(gridExtra)


parl_metadata <- read_csv("data/intermed/parl_text_metadata.csv")

parl_metadata %>% group_by(govt_opp) %>%
  summarise(n_speeches = n(),
            n_speakers = length(unique(speaker))) %>% 
  pivot_longer(cols = -govt_opp, names_to = 'Fidesz-KDNP-Ellenzék') %>% 
  pivot_wider(names_from = govt_opp, values_from = value) %>% 
  mutate(share = government / (opposition + government),
         sum = government + opposition)


p1 <- ggplot(parl_metadata, aes(x = speech_length, color = govt_opp)) +
  geom_histogram(bins=80, fill = "white") + 
  scale_x_log10(
    labels = trans_format("log10", math_format(10^.x))
  ) +
  scale_color_manual(values = c("#fd8100", "#001166")) + 
  ylab("") + 
  xlab("A felszólalások karakterhosszának logaritmusa") +
  theme_bw() +
  theme(legend.position="none")

n_speeches_data <- parl_metadata %>% group_by(speaker) %>% 
  summarise(govt_opp = unique(govt_opp), N = n())

p2 <- ggplot(n_speeches_data, aes(x = N, color = govt_opp)) +
  geom_histogram(bins=50, fill = "white") + 
  scale_x_log10(
    labels = trans_format("log10", math_format(10^.x))
  ) +
  scale_color_manual(labels = c("Fidesz-KDNP", "Ellenzék"), 
                     values = c("#fd8100", "#001166")) + 
  ylab("") + 
  xlab("A képviselőnkénti felszólalások számának logaritmusa") +
  theme_bw() +
  guides(color = guide_legend(override.aes = list(fill = c("#fd8100", "#001166") ) ) ) +
  theme(legend.title = element_blank())

ggsave(
  "speeches_descr.png",
  arrangeGrob(p1, p2, ncol = 2), 
  path = "figures/descriptives/",
  width = 26,
  height = 8,
  units = "cm",
  dpi = 1000,
)

count_plot <- parl_metadata %>% 
  mutate(date = as.Date(date_origin, format="%Y.%m.%d")) %>% 
  group_by(date) %>% 
  summarise( N = n())

dates <- as.data.frame(
  seq(as.Date("2010-5-14"), as.Date("2020-11-23"), by = "days"))
colnames(dates) <- c('date')

count_plot <- merge(dates, count_plot, by = "date", all.x = T)

mean(count_plot$N, na.rm = T)

ggplot(count_plot, aes(x = date, y = N)) + 
  geom_line(na.rm = T) +
  xlab("") +
  ylab("Felszólalások száma") +
  theme_bw()

ggsave(
  "speeches_by_date.png",
  path = "figures/descriptives/",
  width = 26,
  height = 8,
  units = "cm",
  dpi = 700,
)



