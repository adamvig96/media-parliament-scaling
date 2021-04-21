rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(gofastr)


setwd("/Users/vigadam/Dropbox/github/media_network/media_data/parliament_speech_text/")

names <- prep_stopwords(read_csv("data/ogy_nevek_1820.csv")$Név %>% tolower()) #%>% str_replace(" ","_")



sphrases <- prep_stopwords(c("jobbik magyarországért mozgalom","magyar szocialista párt", "lehet más a poitika",
                             "jelent pillanatban","várom érdemi válaszát","egyszer mondom","múlt héten","parlament falai",
                             "napirend utáni","teljesen mindegy","innentől kezdve","szeretném megkérdezni","választ kapni","fidesz",
                             "hölgyeim uraim","szeretném megköszönni","lehetővé teszi","biztosítása érdekében","képviselőtársaimat támogassák",
                             "módosító javaslat","kpéviselőcsoportja","szükségessé vált","program keretében","asszony ház","szeretném elmondani",
                             "öné szó","támogassák javaslatot","gyakorlati tapasztalatok","fentiekre tekintettel",
                             "felmerül kérdés","valamilyen szinten","milliárd forint","forint áll rendelkezésre","kérdésemre adott válaszban",
                             "felhívni figyelmet","kormány figyelmét","felhívni","egyéni képviselői indítvány",
                             "általános vitában elmond*","részt vesz vitában","általános vita","általános vitában","lehetőséget ad"))



swords <- prep_stopwords(append(scan("data/stopwords-hu.txt", what="", sep="\n"),
                 list("tisztelt","képviselő","hát","ur","t","ha","en",
                      "köszönöm","szót","elnök","úr","képviselőtársaim","is","képviselőtársam","képviselőtárs",
                      "összegző","módosítás","jelentés","törvényjavaslat","bizottság","házszabály","országgyűlés",
                      "dr","támogadni","tudjuk","fogjuk","államtitkár","módon","sajnálatos","nyilvánvaló","támogatni","tudjuk",
                      "fogjuk","államtitkár","törvényjavaslat","törvényjavaslatot","törvény","módósításáról","megtisztelő",
                      "figyelmüket","módosítását","törvények","január","szóló","számú","tegnapi","nap","hét","héten","nappal","ezelőtt",
                      "szeretném","kérni","tudom","mondani",  "dolog","fontos","fog","történni","javaslat","módosító","szeretnék","dolgot",
                      "években","nap","széket","tudni","fogják","fogja")))

# df_text <- read_csv("parldata_2020.csv")

df_text <- read_csv("data/parldata_2020.csv")  %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>% dplyr::rename(text = text_strip) %>% 
  drop_na()

corpus <- corpus(df_text %>% select(text))
docvars(corpus, "speaker_party") <- df_text %>% select("speaker_party")
docvars(corpus, "speaker") <- df_text %>% select("speaker")
docvars(corpus, "side") <- df_text %>% select("oldal")

parl_tokens <- tokens(corpus, 
                      remove_punct = T,
                      remove_symbols = T,
                      remove_numbers = T,
                      remove_separators = T) %>% 
               tokens_tolower() %>% 
               tokens_select(pattern = swords, selection = "remove") %>% 
               tokens_select(pattern = phrase(names), selection = "remove") %>% 
               tokens_select(pattern = phrase(sphrases), selection = "remove")

rm(df_text)

#rm(corpus)

#stemming
parl_tokens <- parl_tokens %>% tokens_wordstem(language = 'hu')


# bigramm 
toks_2gram <- tokens_ngrams(parl_tokens, n = 2) #%>% tokens_wordstem(language = 'hu')

bi_dtm <- dfm(toks_2gram, groups = "side") %>%
  dfm_trim(groups = "side", min_termfreq = 20) 

keyness <- bi_dtm %>% textstat_keyness(target=1, measure="chi2")# %>% filter(p<50)

keyness %>% write_csv("data/bigramms_stem.csv")

wordplot <- textplot_keyness(keyness, n=20L, margin=0.15)
jpeg("figures/chi2_bigrams.png",width = 1000, height = 700)
wordplot
dev.off()


# trigramm 

toks_3gram <- tokens_ngrams(parl_tokens, n = 3)

dtm_3gram <- dfm(toks_3gram, groups = "side") %>% 
  dfm_trim(groups = "side",min_termfreq = 10)

keyness <- dtm_3gram %>% textstat_keyness(target=1,measure="chi2") 

keyness %>% write_csv("data/trigramms_stem.csv")

wordplot <- textplot_keyness(keyness,n=30,min_count = 5,margin=0.15)
wordplot

jpeg("figures/chi2_trigrams.png",width = 1000, height = 700)
wordplot
dev.off()















#4gram
toks_4gram <- tokens_ngrams(parl_tokens, n = 4)
dtm_4gram <- dfm(toks_4gram, groups = "side") %>% 
  dfm_trim(groups = "side",min_termfreq = 5,max_termfreq=500)

dtm_4gram <- dtm_4gram %>% dfm_remove(pattern = phrase(sphases), valuetype = "regex")

keyness <- dtm_4gram %>% textstat_keyness(target=1,measure="chi2")

wordplot <- textplot_keyness(keyness,n=30,min_count = 5,margin=0.15)
wordplot


jpeg("figures/chi2_4grams.png",width = 1500, height = 700)
wordplot
dev.off()


toks_Ngram <- tokens_ngrams(parl_tokens, n = 2:4)

dtm_Ngram <- dfm(toks_Ngram, groups = "side") %>% 
  dfm_remove(pattern = names, valuetype = "regex") %>% 
  dfm_trim(min_termfreq = 30,max_termfreq=1000)

dtm_Ngram <- dtm_Ngram %>% dfm_remove(pattern = phrase(sphases), valuetype = "regex")

keyness <- dtm_Ngram %>% textstat_keyness(target=1,measure="chi2")

wordplot <- textplot_keyness(keyness,n=30,min_count = 5,margin=0.15)

wordplot

rm(dtm_4gram,dtm_3gram,toks_3gram,toks_4gram,bi_dtm,toks_2gram)
