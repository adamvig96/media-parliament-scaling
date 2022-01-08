#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

z_score = 1.96
alpha = 1
figname = "slant_estimates_government_opposition.png"


df = (
    pd.read_csv("data/slant_estimates/party_slant_pred.csv")
    .assign(
        side=lambda x: x["party_quarter"].str.split("_").str[0],
        date=lambda x: pd.to_datetime(
            x["party_quarter"].str.replace(" ", "").str.split("_").str[1]
        ),
        se=lambda x: x["se.fit"],
        slant=lambda x: x.groupby("side")["fit"].ewm(alpha=alpha).mean().values,
        ci_lower=lambda x: x["slant"] - z_score * x["se"],
        ci_upper=lambda x: x["slant"] + z_score * x["se"],
    )
    .melt(
        id_vars=["side", "date"],
        value_vars=["slant", "ci_lower", "ci_upper"],
    )
    .assign(
        variable=lambda x: np.where(lambda x: x["variable"] == "slant", "slant", "ci")
    )
)

plt.figure(figsize=(10, 7))
sns.set_theme(style="darkgrid")
sns.lineplot(x="date", y="value", hue="side", style="variable", data=df)
plt.ylabel("Estimated slant")
plt.title("Estimated slant of government and opposition speeches", size=20)
plt.xlabel(None)
plt.legend(bbox_to_anchor=(1, 1), loc=0, borderaxespad=1.0)

plt.savefig("figures/" + figname)


# In[ ]:




