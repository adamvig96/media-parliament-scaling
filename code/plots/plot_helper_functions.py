import numpy as np
import pandas as pd

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


def smooth_time_series(df, alpha=0.4):
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
        #.pipe(detrend_time_series)
        #.pipe(smooth_time_series)
        .assign(se=lambda x: np.where(x["se"] > 0.01, 0.01, x["se"]))
        .pipe(melt_data_for_figure)
    )
    return df