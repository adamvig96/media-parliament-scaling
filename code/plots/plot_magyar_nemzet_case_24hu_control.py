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
figname = "slant_estimates_magyar_nemzet_case_24hu_control.png"

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
plt.title("Online hírportálok torzítottsága:\n a Magyar Nemzet esete", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2022, 1, 1))

# G nap
plt.axvline(dt.datetime(2015, 2, 6), color="#000000")
plt.annotate(
    "G-nap",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.35, 0.75),
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
    xytext=(0.6, 0.67),
    textcoords="axes fraction",
)

plt.savefig("figures/" + figname, dpi=1000)
