#!/usr/bin/env python
# coding: utf-8

import pandas as pd


def drop(df):
    return (
        df.drop_duplicates("url")
        .loc[lambda x: x["content"].notnull()]
        .loc[lambda x: ~x["content"].str[:19].str.contains("description")]
    )


media_corpus_folder = "/Users/adamvig/Dropbox/research/media_corpus/"
output_folder = "data/raw/media-corpus/"

(
    pd.read_pickle(media_corpus_folder + "origo_text_1998-202108.pkl")
    .loc[
        lambda x: (x["date"] >= "2010-01-01")
        & (x["section"].isin(["gazdasag", "itthon"]))
    ]
    .filter(["url", "date", "content"])
    .assign(page="origo.hu")
    .pipe(drop)
).to_csv(output_folder + "origo.csv", index=False)

(
    pd.read_pickle(
        media_corpus_folder + "index_text_2010-202108_belfold_kulfold_gazdasag.pkl"
    )
    .loc[
        lambda x: (x["date"] >= "2010-01-01")
        & (x["rovat_slug"].isin(["gazdasag", "belfold"]))
    ]
    .filter(["date", "url", "text"])
    .rename(columns={"text": "content"})
    .assign(page="index.hu")
    .pipe(drop)
).to_csv(output_folder + "index.csv", index=False)

(
    pd.read_pickle(media_corpus_folder + "mno_text_1998-202101.pkl")
    .loc[
        lambda x: (x["date"] >= "2010-01-01")
        & (x["section"].isin(["gazdasag", "belfold"]))
    ]
    .filter(["date", "url", "content"])
    .assign(page="mno.hu")
    .pipe(drop)
).to_csv(output_folder + "mno.csv", index=False)

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
    .pipe(drop)
).to_csv(output_folder + "444hu.csv", index=False)

(
    pd.read_pickle(media_corpus_folder + "24hu_text_1995-202112.pkl")
    .loc[
        lambda x: (x["date"] >= "2010-01-01")
        & (x["section"].isin(["belfold", "kozelet", "gazdasag"]))
    ]
    .filter(["url", "date", "content"])
    .assign(page="24.hu")
).to_csv(output_folder + "24hu.csv", index=False)

(
    pd.read_pickle(media_corpus_folder + "888_text_2015-202107.pkl")
    .filter(["url", "date", "content"])
    .assign(page="888.hu")
    .pipe(drop)
).to_csv(output_folder + "888hu.csv", index=False)


(
    pd.read_pickle(media_corpus_folder + "atv_text_2008_202202.pkl")
    .loc[lambda x: (x["date"] >= "2010-01-01") & (x["section"] == "belfold")]
    .filter(["url", "date", "content"])
    .assign(page="atv.hu")
    .pipe(drop)
).to_csv(output_folder + "atv.csv", index=False)

(
    pd.read_pickle(media_corpus_folder + "168ora_text_2008-202202.pkl")
    .loc[
        lambda x: (x["date"] >= "2010-01-01") & (x["section"].isin(["itthon", "penz"]))
    ]
    .filter(["url", "date", "content"])
    .assign(page="168ora.hu")
    .pipe(drop)
).to_csv(output_folder + "168ora.csv", index=False)


(
    pd.read_csv(media_corpus_folder + "magyarhang_corpus_201805-202205.csv")
    .loc[lambda x: (x["section"].isin(["Belföld", "Külföld", "Gazdaság"]))]
    .rename(columns={"body": "content", "article_url": "url"})
    .filter(["url", "date", "content"])
    .assign(page="magyarhang.hu")
    .pipe(drop)
).to_csv(output_folder + "magyarhang.csv", index=False)

(
    pd.read_csv(media_corpus_folder + "nepszava_data.csv")
    .filter(["link", "public_date", "content"])
    .assign(page="nepszava.hu")
    .assign(
        date=lambda x: x["public_date"]
        .str.split(" ")
        .str[0]
        .str[:-1]
        .str.replace(".", "-", regex=False)
    )
    .drop("public_date", axis=1)
    .rename(columns={"link": "url"})
    .pipe(drop)
).to_csv(output_folder + "nepszava.csv", index=False)
