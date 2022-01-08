R = R CMD BATCH
STOPWORDS = data/stopwords/stopwords-hu.txt data/stopwords/stopwords-parliament.txt data/stopwords/stopphrases-parliament.txt
YEARS = $(shell seq 2010 2021)

figures/slant_estimates_origo_case.png figures/slant_estimate_magyar_nemzet_case.png&: code/plots/plot_case_studies.py $(foreach year, $(YEARS), data/slant_estimates/monthly_slant_pred_$(year).csv)
	python3 -b $<

$(foreach year, $(YEARS), data/slant_estimates/monthly_slant_pred_$(year).csv)&: code/estimate/predict_media_slant.R data/intermed/wordscore_fit.rds data/intermed/selected_phrases.rds $(foreach year, $(YEARS), data/media_corpus/media_corpus_$(year).rds) 
	$(R) $< logs/predict_media_slant.Rout

$(foreach year, $(YEARS), data/media_corpus/media_corpus_$(year).rds)&: code/clean/create_year_media_corpuses.R data/raw/media_corpus_raw.csv
	$(R) $< logs/create_year_media_corpuses.Rout

data/intermed/wordscore_fit.rds: code/estimate/train_wordscore_model.R data/intermed/parliament_tokens.rds data/intermed/selected_phrases.rds
	$(R) $< logs/train_wordscore_model.Rout

data/intermed/selected_phrases.rds: code/clean/create_selected_phrases.R data/intermed/parliament_tokens.rds
	$(R) $< logs/create_selected_phrases.Rout

data/intermed/parliament_tokens.rds: code/clean/create_parliament_tokens.R data/raw/parlament_speeches_2010-2020.csv $(STOPWORDS)
	$(R) $< logs/create_parliament_tokens.Rout

data/raw/parlament_speeches_2010-2020.csv: code/import/download_parliament_speeches.py
	python3 -b $<