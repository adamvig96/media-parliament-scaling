#!/usr/bin/env python
# coding: utf-8

import datetime as dt

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

z_score = 1.96
alpha = 1
figname = "slant_estimates/government_opposition.png"


df = (
    pd.read_csv("data/slant_estimates/party_slant_pred.csv")
    .assign(
        side=lambda x: x["party_quarter"].str.split("_").str[0],
        date=lambda x: pd.to_datetime(
            x["party_quarter"].str.replace(" ", "").str.split("_").str[1]
        ),
        se=lambda x: x["se.fit"],
        slant=lambda x: x.groupby("side")["fit"].ewm(alpha=alpha).mean().values,
        ci_lower=lambda x: x["slant"] - z_score * x["se"],
        ci_upper=lambda x: x["slant"] + z_score * x["se"],
    )
    .melt(
        id_vars=["side", "date"],
        value_vars=["slant", "ci_lower", "ci_upper"],
    )
    .assign(
        variable=lambda x: np.where(lambda x: x["variable"] == "slant", "slant", "ci")
    )
)

plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#fd8100", "#001166"]
sns.set_palette(sns.color_palette(colors))
sns.lineplot(x="date", y="value", hue="side", style="variable", data=df)
plt.ylabel(None)
plt.ylim(0.25, 0.75)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2021, 1, 1))
# plt.title(
#   "Kormánypárti és ellenzéki képviselők\nfelszólalásainak becsült torzítottsága",
#    y=1.03,
#    size=20,
# )
plt.title(None)
plt.xlabel(None)

govt = mpatches.Patch(color=colors[0], label="Fidesz-KDNP")
opp = mpatches.Patch(color=colors[1], label="Ellenzék")

plt.legend(
    handles=[govt, opp],
    loc=3,
    borderaxespad=2.0,
    title=None,
    frameon=False,
    numpoints=2,
)

plt.savefig("figures/" + figname, dpi=1000)
