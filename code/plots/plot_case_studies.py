import pandas as pd
import numpy as np
from pandas.core import frame
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import warnings
import datetime as dt

warnings.filterwarnings("ignore")


def format_data(df):
    return (
        df.assign(
            site=lambda x: x["site_quarter"].str.split("_").str[0],
            date=lambda x: pd.to_datetime(
                df["site_quarter"].str.replace(" ", "").str.split("_").str[1]
            ),
            se=lambda x: x["se.fit"],
            slant=lambda x: x["fit"],
        )
        .assign(
            site=lambda x: np.where(
                (x["site"] == "mno.hu") & (x["date"] > "2018-06-01"),
                "mno.hu/magyaridok.hu",
                x["site"],
            )
        )
        .filter(["site", "date", "slant", "se"])
        .sort_values(by=["site", "date"])
    )


def detrend_time_series(df):
    return (
        df.merge(
            df.groupby("date")["slant"]
            .mean()
            .reset_index()
            .rename(columns={"slant": "mean_slant"}),
            on="date",
            how="left",
        )
        .assign(slant=lambda x: (x["slant"] - x["mean_slant"]) + x["slant"].mean())
        .drop(["mean_slant"], axis=1)
    )


def smooth_time_series(df, alpha=0.3):
    return df.assign(slant=df.groupby("site")["slant"].ewm(alpha=alpha).mean().values)


def melt_data_for_figure(df, z_score=1.96):
    return (
        df.assign(
            ci_lower=lambda x: x["slant"] - z_score * x["se"],
            ci_upper=lambda x: x["slant"] + z_score * x["se"],
        )
        .melt(
            id_vars=["site", "date"],
            value_vars=["slant", "ci_lower", "ci_upper"],
        )
        .assign(
            variable_type=lambda x: x["variable"],
            variable=lambda x: x["variable"].map(
                {"slant": "slant", "ci_upper": "ci", "ci_lower": "ci"}
            ),
        )
        .rename(columns={"value": "slant"})
        .sort_values(by=["site", "date"])
    )


def execute_formating():
    df = pd.concat(
        [
            pd.read_csv("data/slant_estimates/Q_slant_pred_" + str(year) + ".csv")
            for year in range(2010, 2022)
        ]
    ).loc[lambda x: x["se.fit"] != 0]

    df = (
        df.pipe(format_data)
        .pipe(detrend_time_series)
        .pipe(smooth_time_series)
        .assign(se=lambda x: np.where(x["se"] > 0.01, 0.01, x["se"]))
        .pipe(melt_data_for_figure)
    )
    return df


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
    lambda x: x["site"].isin(["index.hu", "mno.hu", "888.hu", "mno.hu/magyaridok.hu"])
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
