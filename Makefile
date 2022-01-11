R = R CMD BATCH
STOPWORDS = data/stopwords/stopwords-hu.txt data/stopwords/stopwords-parliament.txt data/stopwords/stopphrases-parliament.txt
YEARS = $(shell seq 2010 2021)
SLANT_FIGURES = government_opposition origo_case origo_case_24hu_control magyar_nemzet_case magyar_nemzet_case_24hu_control 
DESCRIPTIVES = speeches_descr speeches_by_date

.PHONY: all
all: $(foreach figure, $(SLANT_FIGURES), figures/slant_estimates/$(figure).png) $(foreach figure, $(DESCRIPTIVES), figures/descriptives/$(figure).png)

# PARLIAMENT SPEECHES ESTIMATES

figures/slant_estimates/government_opposition.png: code/plots/plot_party_slant.py data/slant_estimates/party_slant_pred.csv
	python3 -b $<

data/slant_estimates/party_slant_pred.csv: code/estimate/predict_party_slant.R data/intermed/parliament_tokens.rds data/intermed/selected_phrases.rds data/intermed/wordscore_fit.rds
	$(R) $< logs/predict_party_slant.Rout


# MEDIA SLANT ESTIMATES

figures/slant_estimates/%.png: code/plots/plot_%.py code/plots/plot_helper_functions.py $(foreach year, $(YEARS), data/slant_estimates/Q_slant_pred_$(year).csv)
	python3 -b $<

$(foreach year, $(YEARS), data/slant_estimates/Q_slant_pred_$(year).csv)&: code/estimate/predict_media_slant.R data/intermed/wordscore_fit.rds data/intermed/selected_phrases.rds $(foreach year, $(YEARS), data/media_corpus/media_corpus_$(year).rds) 
	$(R) $< logs/predict_media_slant.Rout

$(foreach year, $(YEARS), data/media_corpus/media_corpus_$(year).rds)&: code/clean/create_year_media_corpuses.R data/raw/media_corpus_raw.csv
	$(R) $< logs/create_year_media_corpuses.Rout

# DESCRIPTIVES

figures/speeches_by_date.png figures/speeches_descr.png&: code/descriptives/parliament_speeches_descriptives.R data/intermed/parl_text_metadata.csv
	$(R) $< logs/parliament_speeches_descriptives.Rout

# TRAIN MODEL

data/intermed/wordscore_fit.rds: code/estimate/train_wordscore_model.R data/intermed/parliament_tokens.rds data/intermed/selected_phrases.rds
	$(R) $< logs/train_wordscore_model.Rout

data/intermed/selected_phrases.rds: code/clean/create_selected_phrases.R data/intermed/parliament_tokens.rds
	$(R) $< logs/create_selected_phrases.Rout

data/intermed/parliament_tokens.rds data/intermed/parl_text_metadata.csv&: code/clean/create_parliament_tokens.R data/raw/parliament_speeches_2010-2020.csv $(STOPWORDS)
	$(R) $< logs/create_parliament_tokens.Rout

# IMPORT RAW DATA

data/raw/parliament_speeches_2010-2020.csv: code/import/download_parliament_speeches.py
	python3 -b $<