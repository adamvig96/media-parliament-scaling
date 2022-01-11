#!/usr/bin/env python
# coding: utf-8


import re
from gzip import decompress
from json import loads

import numpy as np
import pandas as pd
from requests import get
from tqdm import tqdm
from pathlib import Path

tqdm.pandas()


def get_gzipped_json(url):
    return loads(decompress(get(url).content))


# URL-s from this project: https://k-monitor.github.io/parliamentary_debates_open/

corpus_urls = [
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-39.2018-04-29T16-54-06.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-40.2018-04-29T19-09-17.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2018-10-07T13-32-33.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2019-01-27T19-35-32.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2019-04-28T13-42-41.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2019-06-13T19-33-47.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2019-10-23T15-03-10.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2020-01-14T19-25-52.json.gz",
    "https://parldatastorage.blob.core.windows.net/parldata-crawler-results/parldata-41.2020-11-29T14-11-09.json.gz",
]

parldata = pd.DataFrame()
for url in corpus_urls:
    chunk = pd.DataFrame(get_gzipped_json(url))
    chunk["date"] = chunk["plenary_sitting_details"].apply(lambda x: x["date"])
    parldata = pd.concat(
        [parldata, chunk.sort_values(by=["date", "id"]).reset_index(drop=True)]
    )


def get_comments(text, regex, stropstrings):
    result = re.findall(regex, text)
    result.append("()")
    for res in result:
        text = text.replace(res, "").strip()
    for string in stopstrings:
        text = text.replace(string, "").strip()
    return text, result


stopstrings = ["-\n", "\n", "\x0c", "\xad"]
regex = re.compile(".*?\((.*?)\)")

print("Cleaning parliament script")

parldata["text_comm"] = (
    parldata["text"]
    .str.split(":")
    .progress_apply(
        lambda x: get_comments(" ".join(x[1:]), regex, stopstrings)
        if len(x) > 1
        else x[0]
    )
)

parldata["comment"] = parldata["text_comm"].apply(
    lambda x: x[1] if len(x[1]) > 1 else None
)
parldata["text_strip"] = parldata["text_comm"].apply(lambda x: x[0])

parldata = parldata.filter(
    ["date", "speaker", "speaker_party", "type", "bill_title", "text_strip"]
)

Path('./data/raw').mkdir(exist_ok=False)

parldata.to_csv("data/raw/parliament_speeches_2010-2020.csv", index=False)
