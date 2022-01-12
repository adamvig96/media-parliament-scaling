#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import re
import requests
from bs4 import BeautifulSoup


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

# Representative names from 2010 to 2014

strip_name = lambda name: re.sub('(.*) \(.*\).*', '\\1', name)

def get_names_2010_2014():
    data_url = 'https://hu.wikipedia.org/wiki/2010%E2%80%932014_k%C3%B6z%C3%B6tti_magyar_orsz%C3%A1ggy%C5%B1l%C3%A9si_k%C3%A9pvisel%C5%91k_list%C3%A1ja'
    resp = requests.get(data_url)
    soup = BeautifulSoup(resp.content, 'html.parser')
    representative_elem = soup.find('span', id = 'Képviselők').parent
    data = []
    for html_elem in representative_elem.next_siblings:
        if html_elem.name == 'h3':
            party = html_elem.find('span', class_='mw-headline')['id']
        if html_elem.name == 'table':
            data.extend([{'Parlamenti_ciklus': 2010, 'Frakció': party, 'Név': strip_name(name.text)} for name in html_elem.find_all('li')])
        if html_elem.name == 'h2':
            break
    return pd.DataFrame(data)

representative_names = pd.concat([representative_names, get_names_2010_2014()])

representative_names.to_csv("data/raw/representatives_names_2010-2020.csv", index=False)
