import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plots")

from plot_helper_functions import *

df = execute_formating().loc[lambda x: x["site"].isin(["24.hu", "atv.hu", "888.hu"])]
figname = "slant_estimates/atv.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#474755", "#e01164", "#f8343c"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

nyolcas = mpatches.Patch(color=colors[0], label="24.hu")
huszonnegy = mpatches.Patch(color=colors[1], label="888.hu")
atv = mpatches.Patch(color=colors[2], label="atv.hu")

plt.legend(
    handles=[huszonnegy, nyolcas, atv],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("Online hírportálok torzítottsága: atv.hu", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2021, 1, 1))

plt.savefig("figures/" + figname, dpi=1000)
