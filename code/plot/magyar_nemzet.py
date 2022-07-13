import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plot/")

from _helper_functions import *

df = execute_formating(portals=["24hu", "888hu", "mno", "magyarhang"])
figname = "slant_estimates/magyar_nemzet.png"

plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = ["#474755", "#e01164", "yellow", "green", "green"]
sns.set_palette(sns.color_palette(colors))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)


huszonnegy = mpatches.Patch(color=colors[0], label="24.hu")
nyolcas = mpatches.Patch(color=colors[1], label="888.hu")
mhang = mpatches.Patch(color="yellow", label="magyarhang.hu")
mno = mpatches.Patch(color="green", label="magyarnemzet.hu")

plt.legend(
    handles=[nyolcas, huszonnegy, mhang, mno],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("Magyar Nemzet", size=20, y=1.03)
plt.ylabel("Estimated bias")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2021, 1, 1))

plt.axvline(dt.datetime(2015, 2, 6), color="#000000")
plt.annotate(
   "Orbán-Simicska\nfallout",
   xy=(3, 1),
   xycoords="axes fraction",
   xytext=(0.3, 0.73),
   textcoords="axes fraction",
)

plt.savefig("figures/" + figname, dpi=1000)