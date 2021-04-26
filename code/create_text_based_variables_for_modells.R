rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(gofastr)

names <- prep_stopwords(read_csv("data/input/representative_names_2018-2020.csv")$Név %>% tolower()) #%>% str_replace(" ","_")

parl_text <- read_csv("data/input/parlament_speech_2020.csv")  %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>% dplyr::rename(text = text_strip) %>% 
  drop_na()



corpus <- corpus(parl_text %>% select(text))
docvars(corpus, "speaker_party") <- parl_text %>% select("speaker_party")
docvars(corpus, "speaker") <- parl_text %>% select("speaker")
docvars(corpus, "side") <- parl_text %>% select("oldal")

sphrases <- prep_stopwords(c("jobbik magyarországért mozgalom","magyar szocialista párt", "lehet más a poitika",
                             "jelent pillanatban","várom érdemi válaszát","egyszer mondom","múlt héten","parlament falai",
                             "napirend utáni","teljesen mindegy","innentől kezdve","szeretném megkérdezni","választ kapni","fidesz",
                             "hölgyeim uraim","szeretném megköszönni","lehetővé teszi","biztosítása érdekében","képviselőtársaimat támogassák",
                             "módosító javaslat","kpéviselőcsoportja","szükségessé vált","program keretében","asszony ház","szeretném elmondani",
                             "öné szó","támogassák javaslatot","gyakorlati tapasztalatok","fentiekre tekintettel",
                             "felmerül kérdés","valamilyen szinten","milliárd forint","forint áll rendelkezésre","kérdésemre adott válaszban",
                             "felhívni figyelmet","kormány figyelmét","felhívni","egyéni képviselői indítvány",
                             "általános vitában elmond*","részt vesz vitában","általános vita","általános vitában","lehetőséget ad",
                             "ellenzéki képviselők","kormánypárti képviselők"))

swords <- prep_stopwords(append(scan("data/input/stopwords-hu.txt", what="", sep="\n"),
                                list("tisztelt","képviselő","hát","ur","t","ha","en",
                                     "köszönöm","szót","elnök","úr","képviselőtársaim","is","képviselőtársam","képviselőtárs",
                                     "összegző","módosítás","jelentés","törvényjavaslat","bizottság","házszabály","országgyűlés",
                                     "dr","támogadni","tudjuk","fogjuk","államtitkár","módon","sajnálatos","nyilvánvaló","támogatni","tudjuk",
                                     "fogjuk","államtitkár","törvényjavaslat","törvényjavaslatot","törvény","módósításáról","megtisztelő",
                                     "figyelmüket","módosítását","törvények","január","szóló","számú","tegnapi","nap","hét","héten","nappal","ezelőtt",
                                     "szeretném","kérni","tudom","mondani",  "dolog","fontos","fog","történni","javaslat","módosító","szeretnék","dolgot",
                                     "években","nap","széket","tudni","fogják","fogja","szó parancsoljon","választ adni","képviselők")))


parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
               tokens_tolower() %>% 
               tokens_select(pattern = swords, selection = "remove") %>% 
               tokens_select(pattern = phrase(names), selection = "remove") %>% 
               tokens_select(pattern = phrase(sphrases), selection = "remove")

rm(parl_text)


#stemming
parl_tokens <- parl_tokens %>% tokens_wordstem(language = 'hu')


# bigramm 
toks_2gram <- tokens_ngrams(parl_tokens, n = 2)

bi_dtm <- dfm(toks_2gram, groups = "side") %>%
  dfm_trim(groups = "side", min_termfreq = 20) 

bigram_keyness <- bi_dtm %>% textstat_keyness(target=1, measure="chi2")

bigram_keyness <- rbind(bigram_keyness %>% head(500),bigram_keyness %>% tail(500))

bigram_keyness %>% write_csv("data/output/bigramms.csv")

wordplot <- textplot_keyness(bigram_keyness, n=20L, margin=0.15)
jpeg("figures/chi2_bigrams.png",width = 1000, height = 700)
wordplot
dev.off()

# create wordcloud comparison

dfm_group(bi_dtm, 'side') %>% 
  textplot_wordcloud(comparison = TRUE)


# trigramm 

toks_3gram <- tokens_ngrams(parl_tokens, n = 3)

dtm_3gram <- dfm(toks_3gram, groups = "side") %>% 
  dfm_trim(groups = "side",min_termfreq = 10)

trigram_keyness <- dtm_3gram %>% textstat_keyness(target=1,measure="chi2") 

trigram_keyness %>% write_csv("data/output/trigramms.csv")

wordplot <- textplot_keyness(trigram_keyness,n=30,min_count = 5,margin=0.15)
jpeg("figures/chi2_trigrams.png",width = 1000, height = 700)
wordplot
dev.off()

dfm_group(dtm_3gram, 'side') %>% 
  textplot_wordcloud(comparison = TRUE)

rm(list=ls())


# Create final n=1000 phrase list

bigrams <- read_csv("data/output/bigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/output/trigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))

bigrams <-  rbind(bigrams %>% head(250),bigrams %>% tail(250))

trigrams <-  rbind(trigrams %>% head(250),trigrams %>% tail(250))

p <- data.frame(cbind(c(bigrams$feature,trigrams$feature)))

colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p," ","_") 

p %>% write_csv("data/output/p.csv")

rm(list=ls())

# Create phrase frequency tables

#########################################################################################
#         NOTE: it takes a lot of time to run, read tokenized rds file below

df_parl <- read_csv("data/input/parlament_speech_2020.csv") %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>% dplyr::rename(text = text_strip) %>% 
  drop_na() %>% mutate (name = str_replace_all(speaker,"Dr. ",""))

corpus <- corpus(df_parl %>% select(text))
docvars(corpus, "speaker_party") <- df_parl %>% select("speaker_party")
docvars(corpus, "name") <- df_parl %>% select("name")

parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_wordstem(language = 'hu') %>%
  tokens_ngrams(n=2:3) 

parl_tokens %>% write_rds("data/output/parl_tokens.rds")

#########################################################################################
#     read tokenized rds file here

parl_tokens <- read_rds("data/output/parl_tokens.rds")

p <- read_csv("data/output/p.csv")
selected_ps = prep_stopwords(p %>% select(p))

phrase_frequency_table_parliament <- dfm(parl_tokens, groups = "name") %>%
  dfm_select(pattern = phrase(selected_ps), selection = "keep") %>% 
  convert(to="data.frame")

phrase_frequency_table_parliament %>% write_csv("data/output/frequency_of_phrases_parliament.csv")

rm(list=ls())

# Create frequency table for media outlets

#########################################################################################
#         NOTE: it takes a lot of time to run, read tokenized rds file below

df_media <- read_rds("data/output/media_belfold.rds")

corpus <- corpus(df_media %>% select(text))
docvars(corpus, "page") <- df_media %>% select("page")

rm(df_media)

media_tokens <- tokens(corpus, 
                       remove_punct = T,
                       remove_symbols = T,
                       remove_numbers = T,
                       remove_separators = T) %>% 
  tokens_tolower() %>%
  tokens_wordstem(language = 'hu') %>%
  tokens_ngrams(n=2:3) 

rm(corpus)

media_tokens %>% write_rds("data/output/media_tokens.rds")

#########################################################################################
#     Rread tokenized rds file here

media_tokens <- read_rds("data/output/media_tokens.rds")

p <- read_csv("data/output/p.csv")


phrase_frequency_table_media <- dfm(media_tokens,groups = "page") %>% 
  dfm_select(pattern = phrase(prep_stopwords(p %>% select(p))), selection = "keep") %>% 
  convert(to="data.frame")

rm(media_tokens)

phrase_frequency_table_media %>% write_csv("data/output/frequency_of_phrases_media.csv")

