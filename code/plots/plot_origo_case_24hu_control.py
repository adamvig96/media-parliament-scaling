import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plots")

from plot_helper_functions import *

df = execute_formating().loc[lambda x: x["site"].isin(["24.hu", "origo.hu", "888.hu"])]
figname = "slant_estimates_origo_case_24hu_control.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#474755", "#e01164", "#011593"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

nyolcas = mpatches.Patch(color=colors[0], label="24.hu")
huszonnegy = mpatches.Patch(color=colors[1], label="888.hu")
origo = mpatches.Patch(color=colors[2], label="origo.hu")

plt.legend(
    handles=[huszonnegy, nyolcas, origo],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("Online hírportálok torzítottsága:\n az origo.hu esete", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2022, 1, 1))

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
