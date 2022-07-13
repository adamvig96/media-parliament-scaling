import numpy as np
import pandas as pd


def format_data(df):
    return (
        df.assign(
            date=lambda x: pd.to_datetime(df["date"].str.replace(" ", "")),
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
        .assign(
            site=lambda x: np.where(
                (x["site"] == "origo.hu") & (x["date"] >= "2016-01-01"),
                "origo.hu-captured",
                x["site"],
            )
        )
        .loc[lambda x: ~((x["date"] < "2013-09-01") & (x["site"] == "nepszava.hu"))]
        .filter(["site", "date", "slant", "se"])
        .sort_values(by=["site", "date"])
    )


def smooth_time_series(df, alpha=0.35):
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


def execute_formating(portals=["24hu", "888hu", "444hu", "atv", "nepszava", "168ora"]):
    df = pd.concat(
        [pd.read_csv("data/slant_estimates/" + file + ".csv") for file in portals]
    ).loc[lambda x: x["se.fit"] != 0]

    df = (
        df.pipe(format_data)
        .pipe(smooth_time_series)
        .assign(se=lambda x: np.where(x["se"] > 0.01, 0.01, x["se"]))
        .pipe(melt_data_for_figure)
    )
    return df
