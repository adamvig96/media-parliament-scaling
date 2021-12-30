R = R CMD BATCH
STOPWORDS = data/input/stopwords-hu.txt data/input/stopwords-parliament.txt data/input/stopphrases-parliament.txt


data/output/wordscore_fit.rds: code/train_wordscore_model.R data/output/parliament_tokens.rds data/output/selected_phrases.rds
	$(R) $< logs/wordscore_fit.Rout

data/output/selected_phrases.rds: code/create_selected_phrases.R data/output/parliament_tokens.rds
	$(R) $< logs/selected_phrases.Rout

data/output/parliament_tokens.rds: code/create_parliament_tokens.R data/input/parlament_speech_2014-2018.csv $(STOPWORDS)
	$(R) $< logs/parliament_tokens.Rout