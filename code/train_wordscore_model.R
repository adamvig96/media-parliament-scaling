###########################################################################################

# This code:
# 1. select 1000 bigrams and 1000 trigrams with highest ch2 score of predicting 
# whether a speaker is opposition or government.
# 2. Based on these phrases, it trains a wordscore model, to predict opp-govt

###########################################################################################

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

<<<<<<< HEAD
speaker_names <- prep_stopwords(read_csv("data/input/representative_names_2014-2018.csv")$Név %>% tolower())

parl_text <- read_csv("data/input/parlament_speech_2014-2018.csv")  %>% 
=======
names <- prep_stopwords(read_csv("data/input/representative_names_2018-2020.csv")$Név %>% tolower()) #%>% str_replace(" ","_")

parl_text <- read_csv("data/input/parlament_speech_2018-2020.csv")  %>% 
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad
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
  select(c("date", "oldal", "speaker_party", "speaker", "text_strip","type")) %>%
  dplyr::rename(text = text_strip) %>% 
  drop_na() %>% 
  mutate (name = str_replace_all(speaker,"Dr. ",""),
          month = substr(date,6,7),
          label = ifelse(oldal == "ellenzék",0,1),
          date = as.Date(date, format = '%Y.%m.%d.'))

parl_text %>% select("speaker_party") %>% table()

# drop jobbik now
parl_text <- parl_text %>% filter(speaker_party != "Jobbik")

corpus <- corpus(parl_text %>% select(text))
docvars(corpus, "speaker_party") <- parl_text$speaker_party
docvars(corpus, "speaker") <- parl_text$speaker
docvars(corpus, "side") <- parl_text$oldal
docvars(corpus, "label") <- parl_text$label
docvars(corpus, "date") <- parl_text$date

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
               tokens_select(pattern = phrase(speaker_names), selection = "remove") %>% 
               tokens_select(pattern = swords, selection = "remove")

rm(parl_text)
rm(corpus)
<<<<<<< HEAD

=======
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

#stemming
parl_tokens <- parl_tokens %>% tokens_wordstem(language = 'hu')

<<<<<<< HEAD
# Scaling --------------------------------------------------------------
=======
# unigramm 

dtm <- dfm(parl_tokens, groups = "side") %>%
  dfm_trim(groups = "side", min_termfreq = 20) 

unigram_keyness <- dtm %>% textstat_keyness(target=1, measure="chi2")

unigram_keyness %>% write_csv("data/output/unigramms_1820.csv")

textplot_wordcloud(dfm_group(dtm, 'side'), comparison = TRUE,max_words = 100)

>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

# bigramm 
toks_2gram <- tokens_ngrams(parl_tokens, n = 2)

bi_dtm <- dfm(toks_2gram) %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 20) 

bigram_keyness <- bi_dtm %>% textstat_keyness(target=1, measure="chi2")

<<<<<<< HEAD
bigram_keyness %>% write_csv("data/output/bigramms_1418_wojobbik.csv")
=======
bigram_keyness %>% write_csv("data/output/bigramms_1820.csv")

# create wordcloud comparison

textplot_wordcloud(dfm_group(bi_dtm, 'side'), comparison = TRUE,max_words = 100)

dev.off()
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

textplot_wordcloud(dfm_group(bi_dtm, groups = side), comparison = TRUE,max_words = 100)

# trigramm 

toks_3gram <- tokens_ngrams(parl_tokens, n = 3)

dtm_3gram <- dfm(toks_3gram) %>%
  dfm_group(groups = side) %>%
  dfm_trim(groups = side, min_termfreq = 20) 

trigram_keyness <- dtm_3gram %>% textstat_keyness(target=1,measure="chi2") 

<<<<<<< HEAD
trigram_keyness %>% write_csv("data/output/trigramms_1418_wojobbik.csv")
=======
trigram_keyness %>% write_csv("data/output/trigramms_1820.csv")
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

wordplot <- textplot_keyness(trigram_keyness,n=30,min_count = 5,margin=0.15)

textplot_keyness(trigram_keyness)

# create wordcloud comparison
dfm_group(dtm_3gram, groups = side) %>% 
  textplot_wordcloud(comparison = TRUE,max_words = 100)


# Create final n=2000 phrase list

<<<<<<< HEAD
bigrams <- read_csv("data/output/bigramms_1418_wojobbik.csv") %>%
  mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/output/trigramms_1418_wojobbik.csv") %>%
  mutate(feature = str_replace_all(feature,"_"," "))
=======
unigrams <- read_csv("data/output/unigramms_1820.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
bigrams <- read_csv("data/output/bigramms_1820.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/output/trigramms_1820.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))

unigrams <- read_csv("data/output/unigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
bigrams <- read_csv("data/output/bigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
trigrams <- read_csv("data/output/trigramms.csv") %>% mutate(feature = str_replace_all(feature,"_"," "))
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

unigrams <-  rbind(bigrams %>% head(500),unigrams %>% tail(500))
bigrams <-  rbind(bigrams %>% head(500),bigrams %>% tail(500))
trigrams <-  rbind(trigrams %>% head(500),trigrams %>% tail(500))

p <- data.frame(cbind(c(unigrams$feature,bigrams$feature,trigrams$feature)))

p <- data.frame(cbind(c(bigrams$feature,trigrams$feature)))

colnames(p)[1] <- "p"
p$p <- str_replace_all(p$p," ","_") 

selected_ps <-  prep_stopwords(p %>% select(p))

<<<<<<< HEAD
selected_ps %>% write_rds("data/output/selected_parl_phrases_1418_wojobbik.rds")

# Create phrase frequencies of selected phrases in parltext

selected_ps <- read_rds("data/output/selected_parl_phrases_1418_wojobbik.rds")
=======
selected_ps %>% write_rds("data/output/selected_parl_phrases_1820.rds")
selected_ps %>% write_rds("data/output/selected_parl_phrases_1920_wuni.rds")
selected_ps %>% write_rds("data/output/selected_parl_phrases_1820_wuni.rds")

# Create phrase frequencies of selected phrases in parltext

selected_ps <- read_rds("data/output/selected_parl_phrases_1820.rds")
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

selected_parl_tokens <- parl_tokens %>% tokens_ngrams(n=2:3) %>%
  tokens_select(pattern = phrase(selected_ps), selection = "keep")

<<<<<<< HEAD
=======
# phrase_frequency_table_parliament <- dfm(selected_parl_tokens, groups = "label")
phrase_frequency_table_parliament <- dfm(selected_parl_tokens)
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad

phrase_frequency_table_parliament <- dfm(selected_parl_tokens)

# train wordscore model
tmod_ws <- textmodel_wordscores(phrase_frequency_table_parliament, 
<<<<<<< HEAD
                                y = phrase_frequency_table_parliament$label,
                                smooth = 0)
summary(tmod_ws)

tmod_ws %>% write_rds("data/output/wordscore_fit_1418_wojobbik.rds")
=======
                                y = phrase_frequency_table_parliament$label, smooth = 0)
summary(tmod_ws)

tmod_ws %>% write_rds("data/output/wordscore_fit_1820_pred_speaker_smmoth.rds")

tmod_ws_old <- read_rds("data/output/wordscore_fit_1920_old.rds")

summary(tmod_ws_old)


rm(list=ls())
>>>>>>> 80c4926aeb252dc88c571ade4a57fe998808b7ad
