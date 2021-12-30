R = R CMD BATCH
STOPWORDS = data/stopwords/stopwords-hu.txt data/stopwords/stopwords-parliament.txt data/stopwords/stopphrases-parliament.txt

data/output/monthly_slant_pred.csv: code/predict_media_slant.R data/output/wordscore_fit.rds data/output/selected_phrases.rds data/output/index_case_corpus.rds 
	$(R) $< logs/monthly_slant_pred.Rout

data/output/wordscore_fit.rds: code/train_wordscore_model.R data/output/parliament_tokens.rds data/output/selected_phrases.rds
	$(R) $< logs/wordscore_fit.Rout

data/output/selected_phrases.rds: code/create_selected_phrases.R data/output/parliament_tokens.rds
	$(R) $< logs/selected_phrases.Rout

data/output/parliament_tokens.rds: code/create_parliament_tokens.R data/input/parlament_speech_2014-2018.csv $(STOPWORDS)
	$(R) $< logs/parliament_tokens.Rout

data/output/index_case_corpus.rds: code/create_case_media_corpuses.R
	$(R) $< logs/create_case_media_corpuses.Rout