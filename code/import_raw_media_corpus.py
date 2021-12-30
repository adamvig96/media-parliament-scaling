#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import os

media_corpus_folder = "/Users/adamvig/Dropbox/research/media_corpus/"

corpus_files = [file for file in os.listdir(media_corpus_folder) if ".pkl" in file]
corpus_files.remove("index_v0_9_1.pkl")

(
    pd.concat(
        [
            (
                pd.read_pickle(media_corpus_folder + corpus_files[0])
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["gazdasag", "itthon"]))
                ]
                .filter(["url", "date", "content"])
                .assign(page="origo.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + corpus_files[1])
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["rovat_slug"].isin(["gazdasag", "belfold"]))
                ]
                .filter(["date", "url", "text"])
                .rename(columns={"text": "content"})
                .assign(page="index.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + corpus_files[2])
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["gazdasag", "belfold"]))
                ]
                .filter(["date", "url", "content"])
                .assign(page="mno.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + corpus_files[3])
                .loc[
                    lambda x: x["section"].isin(
                        [
                            "politika",
                            "gazdaság",
                            "egészségügy",
                            "budapest",
                            "oktatás",
                            "migráció",
                            "belföld",
                            "parlament",
                            "elmebaj",
                            "választás",
                            "képmutatás a köbön",
                            "ennyike",
                        ]
                    )
                ]
                .filter(["url", "date", "content"])
                .assign(page="444.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + corpus_files[4])
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["belfold", "kozelet", "gazdasag"]))
                ]
                .filter(["url", "date", "content"])
                .assign(page="24.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + corpus_files[5])
                .filter(["url", "date", "content"])
                .assign(page="888.hu")
            ),
        ]
    )
    .drop_duplicates("url")
    .loc[lambda x: x["content"].notnull()]
    .assign(text_length=lambda x: x["content"].apply(len))
    .loc[lambda x: x["text_length"] > 70]
    .drop("text_length", axis=1)
    .loc[lambda x: ~x["content"].str[:19].str.contains("description")]
).to_csv("data/raw/media_corpus_raw.csv", index=False)

