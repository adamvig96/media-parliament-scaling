import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plot/")

from _helper_functions import *

df = execute_formating(portals=["24hu", "888hu", "index"])
figname = "slant_estimates/index.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = {
    "24.hu": "#474755",
    "888.hu": "#e01164",
    "index.hu": "#f89424",
    "index.hu-captured": "#f89424",
}

sns.set_palette(sns.color_palette(colors.values()))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

_24hu = mpatches.Patch(color=colors["24.hu"], label="24.hu")
index = mpatches.Patch(color=colors["index.hu"], label="index.hu")
_888hu = mpatches.Patch(color=colors["888.hu"], label="888.hu")

plt.legend(
    handles=[_888hu, _24hu, index],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("index.hu", size=20, y=1.03)
plt.ylabel("Estimated bias")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2023, 1, 1))

plt.axvline(dt.datetime(2020, 7, 22), color="#000000")
plt.annotate(
    "change of editor",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.3, 0.15),
    textcoords="axes fraction",
    ha="center",
    va="center",
)


plt.savefig("figures/" + figname, dpi=1000)
