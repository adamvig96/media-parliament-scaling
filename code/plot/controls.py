import datetime as dt
import sys
import warnings

import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore")
sys.path.append("code/plot/")

from _helper_functions import *

df = execute_formating(
    portals=["24hu", "888hu", "444hu", "index", "atv", "nepszava", "168ora"]
)
figname = "slant_estimates/controls.png"


plt.figure(figsize=(10, 7))
sns.set_theme(style="whitegrid")
colors = {
    "168ora.hu": "red",
    "24.hu": "#474755",
    "444.hu": "#ffec24",
    "888.hu": "#e01164",
    "index.hu": "#f89424",
    "nepszava.hu": "#167EFC",
    "atv.hu": "#f8343c",
}

sns.set_palette(sns.color_palette(colors.values()))

sns.lineplot(x="date", y="slant", hue="site", style="variable", data=df)

_24hu = mpatches.Patch(color=colors["24.hu"], label="24.hu")
index = mpatches.Patch(color=colors["index.hu"], label="index.hu")
_444hu = mpatches.Patch(color=colors["444.hu"], label="444.hu")
_888hu = mpatches.Patch(color=colors["888.hu"], label="888.hu")
atv = mpatches.Patch(color=colors["atv.hu"], label="atv.hu")
nepszava = mpatches.Patch(color=colors["nepszava.hu"], label="nepszava.hu")
_168ora = mpatches.Patch(color=colors["168ora.hu"], label="168ora.hu")

plt.legend(
    handles=[_888hu, _24hu, _168ora, index, _444hu, atv, nepszava],
    loc=0,
    borderaxespad=1.0,
    frameon=False,
    title=False,
    numpoints=3,
)
plt.title("News portals without change in ownership", size=20, y=1.03)
plt.ylabel("Estimated bias")
plt.xlabel(None)
plt.ylim(0.4, 0.65)
plt.xlim(dt.datetime(2010, 1, 1), dt.datetime(2021, 1, 1))

plt.savefig("figures/" + figname, dpi=1000)
