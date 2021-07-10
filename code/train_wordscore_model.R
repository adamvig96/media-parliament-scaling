###########################################################################################

# This code:
# 1. select 1000 bigrams and 1000 trigrams with highest ch2 score of predicting a speaker is
# opposition or government.
# 2. Based on these phrases, it trains a wordscore model, to predict opp-govt

###########################################################################################


rm(list=ls())

library(dplyr)
library(ggplot2)
library(quanteda)
require(quanteda.textmodels)
library(tidyverse)
library(gofastr)

names <- prep_stopwords(read_csv("data/input/representative_names_2018-2020.csv")$Név %>% tolower()) #%>% str_replace(" ","_")

parl_text <- read_csv("data/input/parlament_speech_2019-2020.csv")  %>% 
  filter(type == "vezérszónoki felszólalás" | type == "felszólalás" | type == "elhangzik az interpelláció/kérdés/azonnali kérdés"
         | type == "azonnali kérdésre adott képviselői viszonválasz" | type == "azonnali kérdésre adott képviselői viszonválasz"
         | type == "kétperces felszólalás" | type == "kérdés megválaszolva" | type == "napirend előttihez hozzászólás" 
         | type == "napirend előtti felszólalás" | type == "napirend előtti felszólalás" | type == "azonnali kérdésre adott miniszteri viszonválasz"
         | type == "napirend utáni felszólalás" | type == "Előadói válasz"
         | type == "előterjesztő nyitóbeszéde" | type == "interpelláció szóban megválaszolva") %>%
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>%
  dplyr::rename(text = text_strip) %>% 
  drop_na() %>% 
  mutate (name = str_replace_all(speaker,"Dr. ",""),
          month = substr(date,6,7),
          label = ifelse(oldal == "ellenzék",0,1))



corpus <- corpus(parl_text %>% select(text))
docvars(corpus, "speaker_party") <- parl_text$speaker_party
docvars(corpus, "speaker") <- parl_text$speaker
docvars(corpus, "side") <- parl_text$oldal
docvars(corpus, "label") <- parl_text$label

sphrases <- prep_stopwords(c("jobbik magyarországért mozgalom","magyar szocialista párt", "lehet más a poitika",
                             "jelent pillanatban","várom érdemi válaszát","egyszer mondom","múlt héten","parlament falai",
                             "napirend utáni","teljesen mindegy","innentől kezdve","szeretném megkérdezni","választ kapni","fidesz",
                             "hölgyeim uraim","szeretném megköszönni","lehetővé teszi","biztosítása érdekében","képviselőtársaimat támogassák",
                             "módosító javaslat","kpéviselőcsoportja","szükségessé vált","program keretében","asszony ház","szeretném elmondani",
                             "öné szó","támogassák javaslatot","gyakorlati tapasztalatok","fentiekre tekintettel",
                             "felmerül kérdés","valamilyen szinten","milliárd forint","forint áll rendelkezésre","kérdésemre adott válaszban",
                             "felhívni figyelmet","kormány figyelmét","felhívni","egyéni képviselői indítvány",
                             "általános vitában elmond*","részt vesz vitában","általános vita","általános vitában","lehetőséget ad",
                             "ellenzéki képviselők","kormánypárti képviselők","teljesen világos","várom válaszát","őszintén szólva",
                             "tisztelettel tájékoztatom","kdnp-frakció támogatja","képviselőcsoportja támogatja","elhangzottakra tekintettel",
                             "kdnp támogatja","illeti szó","részt vesz vitában","miniszter úr","fidesz-frakcióhoz hasonlóan","fidesz-frakció",
                             "illeti a szó parancsoljon","öné a szó","hölgyeim és uraim","jelen pillanatban"))

swords <- prep_stopwords(append(scan("data/input/stopwords-hu.txt", what="", sep="\n"),
                                list("tisztelt","képviselő","hát","ur","t","ha","en", "parancsoljon",
                                     "köszönöm","szót","elnök","úr","képviselőtársaim","is","képviselőtársam","képviselőtárs","képviselőcsoportja",
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
               tokens_select(pattern = phrase(sphrases), selection = "remove") %>% 
               tokens_select(pattern = phrase(names), selection = "remove") %>% 
               tokens_select(pattern = swords, selection = "remove")

rm(parl_text)

#stemming
parl_tokens <- parl_tokens %>% tokens_wordstem(language = 'hu')


# bigramm 
toks_2gram <- tokens_ngrams(parl_tokens, n = 2)

bi_dtm <- dfm(toks_2gram, groups = "side") %>%
  dfm_trim(groups = "side", min_termfreq = 20) 

bigram_keyness <- bi_dtm %>% textstat_keyness(target=1, measure="chi2")

bigram_keyness %>% write_csv("data/output/bigramms.csv")

# create wordcloud comparison

textplot_wordcloud(dfm_group(bi_dtm, 'side'), comparison = TRUE,max_words = 100)

dev.off()


# trigramm 

toks_3gram <- tokens_ngrams(parl_tokens, n = 3)

dtm_3gram <- dfm(toks_3gram, groups = "side") %>% 
  dfm_trim(groups = "side",min_termfreq = 10)

trigram_keyness <- dtm_3gram %>% textstat_keyness(target=1,measure="chi2") 

trigram_keyness %>% write_csv("data/output/trigramms.csv")

wordplot <- textplot_keyness(trigram_keyness,n=30,min_count = 5,margin=0.15)

# create wordcloud comparison
dfm_group(dtm_3gram, 'side') %>% 
  textplot_wordcloud(comparison = TRUE,max_words = 100)


# Create final n=2000 phrase list

bigrams <- read_csv("data/output/bigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/output/trigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))

bigrams <-  rbind(bigrams %>% head(500),bigrams %>% tail(500))

trigrams <-  rbind(trigrams %>% head(500),trigrams %>% tail(500))

p <- data.frame(cbind(c(bigrams$feature,trigrams$feature)))

colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p," ","_") 

p %>% write_csv("data/output/p_1920.csv")

# Create phrase frequencies of selected phrases in parltext

selected_ps = prep_stopwords(p %>% select(p))

selected_parl_tokens <- parl_tokens %>% tokens_ngrams(n=2:3) %>%
  tokens_select(pattern = phrase(selected_ps), selection = "keep")

phrase_frequency_table_parliament <- dfm(selected_parl_tokens, groups = "label")


# train wordscore model
tmod_ws <- textmodel_wordscores(phrase_frequency_table_parliament, 
                                y = phrase_frequency_table_parliament$label, smooth = 1)
summary(tmod_ws)

tmod_ws %>% write_rds("data/output/wordscore_fit_1920.rds")

tmod_ws_old <- read_rds("data/output/wordscore_fit_1920_old.rds")

summary(tmod_ws_old)


rm(list=ls())