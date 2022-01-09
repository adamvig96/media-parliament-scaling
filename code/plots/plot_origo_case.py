import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plots")

from plot_helper_functions import *

df = execute_formating().loc[
    lambda x: x["site"].isin(["index.hu", "origo.hu", "888.hu"])
]
figname = "slant_estimates_origo_case.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#e01164", "#f4941c", "#011593"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

nyolcas = mpatches.Patch(color=colors[0], label="888.hu")
index = mpatches.Patch(color=colors[1], label="index.hu")
origo = mpatches.Patch(color=colors[2], label="origo.hu")

plt.legend(
    handles=[nyolcas, index, origo],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
    labels=["888.hu", "index.hu", "origo.hu"],
)
plt.title("Online hírportálok torzítottsága:\n az origo.hu esete", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)

# change of editor
plt.axvline(dt.datetime(2014, 6, 2), color="#000000")
plt.annotate(
    "origo.hu\nszerkesztőváltás",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.3, 0.15),
    textcoords="axes fraction",
    ha="center",
    va="center",
)

# change of owner
plt.axvline(dt.datetime(2015, 12, 7), color="#000000")
plt.annotate(
    "origo.hu\ntulajdonosváltás",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.61, 0.15),
    textcoords="axes fraction",
    ha="center",
    va="center",
)

plt.savefig("figures/" + figname, dpi=1000)


df = execute_formating().loc[
    lambda x: x["site"].isin(["24.hu", "mno.hu", "888.hu", "mno.hu/magyaridok.hu"])
]
figname = "slant_estimates_magyar_nemzet_case.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#e01164", "#f4941c", "#133c5c", "#133c5c"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)


nyolcas = mpatches.Patch(color=colors[0], label="888.hu")
index = mpatches.Patch(color=colors[1], label="index.hu")
mno = mpatches.Patch(color=colors[2], label="mno.hu")

plt.legend(
    handles=[nyolcas, index, mno],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
    labels=["888.hu", "index.hu", "mno.hu"],
)
plt.title("Online hírportálok torzítottsága:\n a Magyar Nemzet esete", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)

# G nap
plt.axvline(dt.datetime(2015, 2, 6), color="#000000")
plt.annotate(
    "G-nap",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.38, 0.83),
    textcoords="axes fraction",
)
plt.annotate(
    "Simicska\n bezár",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.65, 0.15),
    textcoords="axes fraction",
)
plt.annotate(
    "Magyar Idők nevet vált\nMagyar Nemzetre",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.6, 0.59),
    textcoords="axes fraction",
)

plt.savefig("figures/" + figname, dpi=1000)
