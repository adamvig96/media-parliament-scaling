import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plots")

from plot_helper_functions import *

df = execute_formating().loc[
    lambda x: x["site"].isin(["24.hu", "mno.hu", "888.hu", "mno.hu/magyaridok.hu"])
]
figname = "slant_estimates/magyar_nemzet.png"

plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#474755", "#e01164", "#133c5c", "#133c5c"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)


huszonnegy = mpatches.Patch(color=colors[0], label="24.hu")
nyolcas = mpatches.Patch(color=colors[1], label="888.hu")
mno = mpatches.Patch(color=colors[2], label="mno.hu")

plt.legend(
    handles=[nyolcas, huszonnegy, mno],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("Online hírportálok torzítottsága: Magyar Nemzet", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2021, 1, 1))

# G nap
plt.axvline(dt.datetime(2015, 2, 6), color="#000000")
plt.annotate(
    "Orbán-Simicska\nháború kezdete",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.3, 0.73),
    textcoords="axes fraction",
)
plt.annotate(
    "Simicska\n kivonul",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.65, 0.13),
    textcoords="axes fraction",
)
plt.annotate(
    "Magyar Idők nevet vált\nMagyar Nemzetre",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.7, 0.7),
    textcoords="axes fraction",
)

plt.savefig("figures/" + figname, dpi=1000)
