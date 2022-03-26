import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plots")

from plot_helper_functions import *

df = execute_formating().loc[lambda x: x["site"].isin(["24.hu", "168ora.hu", "888.hu"])]
figname = "slant_estimates/168ora_case.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#d0040c","#474755", "#e01164"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

nyolcas = mpatches.Patch(color=colors[0], label="168ora.hu")
huszonnegy = mpatches.Patch(color=colors[1], label="24.hu")
szazhatvannyolc = mpatches.Patch(color=colors[2], label="888.hu")

plt.legend(
    handles=[huszonnegy, nyolcas, szazhatvannyolc],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("Online hírportálok torzítottsága:\n 168ora.hu", size=20, y=1.03)
plt.ylabel("Becsült torzítottság")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2022, 4, 1))

plt.savefig("figures/" + figname, dpi=1000)
