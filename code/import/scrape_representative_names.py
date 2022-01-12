#!/usr/bin/env python
# coding: utf-8

import pandas as pd

represenentative_names_wikipedia = [
    # "https://hu.wikipedia.org/wiki/2010%E2%80%932014_k%C3%B6z%C3%B6tti_magyar_orsz%C3%A1ggy%C5%B1l%C3%A9si_k%C3%A9pvisel%C5%91k_list%C3%A1ja",
    "https://hu.wikipedia.org/wiki/2014%E2%80%932018_k%C3%B6z%C3%B6tti_magyar_orsz%C3%A1ggy%C5%B1l%C3%A9si_k%C3%A9pvisel%C5%91k_list%C3%A1ja",
    "https://hu.wikipedia.org/wiki/2018%E2%80%932022_k%C3%B6z%C3%B6tti_magyar_orsz%C3%A1ggy%C5%B1l%C3%A9si_k%C3%A9pvisel%C5%91k_list%C3%A1ja",
]

representative_names = []
for url in represenentative_names_wikipedia:
    term_table = pd.read_html(url)

    representative_names.append(
        pd.concat(
            [
                term_table[3],
                term_table[4],
                term_table[5],
            ]
        ).assign(Parlamenti_ciklus=url.split("%")[0][-4:])
    )

representative_names = (
    pd.concat(representative_names)
    .dropna(subset=["Név"])
    .assign(Név=lambda x: x["Név"].str.split("[").apply(lambda x: x[0]))
).filter(
    [
        "Frakció",
        "Mandátum kezdete",
        "Mandátum vége",
        "Név",
        "Választókerület",
        "Parlamenti_ciklus",
    ]
)

representative_names.to_csv("data/raw/representatives_names_2014-2020.csv", index=False)
