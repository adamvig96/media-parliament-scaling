R = R CMD BATCH
STOPWORDS = data/stopwords/stopwords-hu.txt data/stopwords/stopwords-parliament.txt data/stopwords/stopphrases-parliament.txt
MEDIA = 168ora 444hu atv magyarhang nepszava 24hu 888hu index mno origo
SLANT_FIGURES = government_opposition origo magyar_nemzet index controls
DESCRIPTIVES = speeches_descr speeches_by_date

.PHONY: all
all: $(foreach figure, $(SLANT_FIGURES), figures/slant_estimates/$(figure).png) $(foreach figure, $(DESCRIPTIVES), figures/descriptives/$(figure).png)

# PARLIAMENT SPEECHES ESTIMATES

figures/slant_estimates/government_opposition.png: code/plot/party_slant.py data/slant_estimates/party_slant_pred.csv
	python3 -b $<

data/slant_estimates/party_slant_pred.csv: code/estimate/predict_party_slant.R data/intermed/parliament_tokens.rds data/intermed/selected_phrases.rds data/intermed/wordscore_fit.rds
	$(R) $< logs/predict_party_slant.Rout


# MEDIA SLANT ESTIMATES

figures/slant_estimates/%.png: code/plot/%.py code/plot/_helper_functions.py $(foreach media, $(MEDIA), data/slant_estimates/$(media).csv)
	python3 -b $<

data/slant_estimates/%.csv: code/estimate/media-slant/%.R data/raw/media-corpus/%.csv code/estimate/media-slant/_helper_functions.R data/intermed/wordscore_fit.rds data/intermed/selected_phrases.rds
	$(R) $< logs/$*.Rout


# DESCRIPTIVES

figures/descriptives/speeches_by_date.png figures/descriptives/speeches_descr.png&: code/descriptives/parliament_speeches_descriptives.R data/intermed/parl_text_metadata.csv
	$(R) $< logs/parliament_speeches_descriptives.Rout

# TRAIN MODEL

data/intermed/wordscore_fit.rds: code/estimate/train_wordscore_model.R data/intermed/parliament_tokens.rds data/intermed/selected_phrases.rds
	$(R) $< logs/train_wordscore_model.Rout

data/intermed/selected_phrases.rds: code/clean/create_selected_phrases.R data/intermed/parliament_tokens.rds
	$(R) $< logs/create_selected_phrases.Rout

data/intermed/parliament_tokens.rds data/intermed/parl_text_metadata.csv&: code/clean/create_parliament_tokens.R data/raw/parliament_speeches_2010-2020.csv data/raw/representatives_names_2010-2020.csv $(STOPWORDS)
	$(R) $< logs/create_parliament_tokens.Rout

# IMPORT RAW DATA

data/raw/parliament_speeches_2010-2020.csv: code/import/download_parliament_speeches.py
	python3 -b $<

data/raw/representatives_names_2010-2020.csv: code/import/scrape_representative_names.py
	python3 -b $<