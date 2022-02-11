#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import os

media_corpus_folder = "/Users/adamvig/Dropbox/research/media_corpus/"

(
    pd.concat(
        [
            (
                pd.read_pickle(media_corpus_folder + "origo_text_1998-202108.pkl")
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["gazdasag", "itthon"]))
                ]
                .filter(["url", "date", "content"])
                .assign(page="origo.hu")
            ),
            (
                pd.read_pickle(
                    media_corpus_folder
                    + "index_text_2010-202108_belfold_kulfold_gazdasag.pkl"
                )
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["rovat_slug"].isin(["gazdasag", "belfold"]))
                ]
                .filter(["date", "url", "text"])
                .rename(columns={"text": "content"})
                .assign(page="index.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + "mno_text_1998-202101.pkl")
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["gazdasag", "belfold"]))
                ]
                .filter(["date", "url", "content"])
                .assign(page="mno.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + "444_text_2013-2020.pkl")
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
                pd.read_pickle(media_corpus_folder + "24hu_text_1995-202112.pkl")
                .loc[
                    lambda x: (x["date"] >= "2010-01-01")
                    & (x["section"].isin(["belfold", "kozelet", "gazdasag"]))
                ]
                .filter(["url", "date", "content"])
                .assign(page="24.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + "888_text_2015-202107.pkl")
                .filter(["url", "date", "content"])
                .assign(page="888.hu")
            ),
            (
                pd.read_pickle(media_corpus_folder + "atv_text_2008_202202.pkl")
                .filter(["url", "date", "content"])
                .loc[lambda x: x["date"] >= "2010-01-01"]
                .assign(page="atv.hu")
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
