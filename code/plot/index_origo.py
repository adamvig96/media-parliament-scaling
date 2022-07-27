import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plot/")

from _helper_functions import *

df = execute_formating(portals=["24hu", "origo", "index"])
figname = "slant_estimates/index_origo.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = {
    "24.hu": "#474755",
    "index.hu": "#f89424",
    "index.hu-captured": "#f89424",
    "origo.hu": "#011593",
    "origo.hu-captured": "#011593",
}

sns.set_palette(sns.color_palette(colors.values()))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

_24hu = mpatches.Patch(color=colors["24.hu"], label="24.hu")
index = mpatches.Patch(color=colors["index.hu"], label="index.hu")
origo = mpatches.Patch(color=colors["origo.hu"], label="origo.hu")

plt.legend(
    handles=[origo, _24hu, index],
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


#ORIGO
## change of owner
plt.axvline(dt.datetime(2015, 12, 7), color="#000000")
plt.annotate(
    "Origo capture",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.36, 0.15),
    textcoords="axes fraction",
    ha="center",
    va="center",
)

#INDEX
plt.axvline(dt.datetime(2020, 7, 22), color="#000000")
plt.annotate(
    "Index capture",
    xy=(3, 1),
    xycoords="axes fraction",
    xytext=(0.73, 0.15),
    textcoords="axes fraction",
    ha="center",
    va="center",
)

plt.savefig("figures/" + figname, dpi=1000)
