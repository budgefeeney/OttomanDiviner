#!/home/bryanfeeney/anaconda3/bin/python3.6

#
# Simple script that uses the Microsoft Light Gradient-Boosted Machine-Learnign
# toolkit to make predictions *separately* for each value.
#

from datetime import date, timedelta, datetime

import pandas as pd
import numpy as np
from sklearn.metrics import mean_squared_error
import lightgbm as lgb
import sys
import os

FutureDaysToCalculate=16
WeeksOfHistoryForFeature=8
WeeksOfHistoryForFeatureOnTest=3

def load_data_csv (cumul_sale_path, cumul_sale_future_path, items_path, stores_path):
    """
    Loads three datasets from the file-system in CSV format:

    train is the cumulative sales data, should be the last 12 months
    items is item data
    stores is store data
    """
    df_train = pd.read_csv(
        cumul_sale_tbl,
        usecols=[1, 2, 3, 4, 5],
        dtype={'onpromotion': bool},
        converters={'unit_sales': lambda u: np.log1p(float(u)) if float(u) > 0 else 0},
        parse_dates=["date"]
    )

    if cumul_sale_future_path is not None:
        df_test = pd.read_csv(
            cumul_sale_future_path,
            usecols=[0, 1, 2, 3, 4],
            dtype={'onpromotion': bool},
            parse_dates=["date"],
        ).set_index(
            ['store_nbr', 'item_nbr', 'date']
        )

    items = pd.read_csv(
        items_tbl,
    ).set_index("item_nbr")

    stores = pd.read_csv(
        stores_tbl
    ).set_index("store_nbr")

    return df_train, df_test, items, stores


def generate_promo_variables(cumul_sales, cumul_sales_future):
    """
    Generate a column for each of the next 16 days with 1 if there is a
    store-item pair for which a promotion exist on that day, and 0 otherwise.
    """
    promo_variables_train = cumul_sales.set_index(
        ["store_nbr", "item_nbr", "date"])[["onpromotion"]].unstack(
            level=-1).fillna(False)
    promo_variables_train.columns = promo_variables_train.columns.get_level_values(1)

    promo_variables_test = cumul_sales_future[["onpromotion"]].unstack(level=-1).fillna(False)
    promo_variables_test.columns = promo_variables_test.columns.get_level_values(1)
    promo_variables_test = promo_variables_test.reindex(promo_variables_train.index).fillna(False)

    promo_variables = pd.concat([promo_variables_train, promo_variables_test], axis=1)

    del promo_variables_train, promo_variables_test

    return promo_variables

def generate_unit_sales_columns(cumul_sales):
    cumul_sales = cumul_sales.set_index(
    ["store_nbr", "item_nbr", "date"])[["unit_sales"]].unstack(
        level=-1).fillna(0)
    cumul_sales.columns = cumul_sales.columns.get_level_values(1)
    return cumul_sales

def get_timespan(dataset, dt, minus, periods):
    return dataset[
        pd.date_range(dt - timedelta(days=minus), periods=periods)
    ]

def prepare_dataset(cumul_sales, promos, start_date, is_train=True):
    """
    Takes two dataframes and fuses them together to form a single features
    matrix.

    cumul_sales : Used to generate mean sales for the last three days, seven
    days etc.
    promos : Used to generate features to say is a promotion for a single
    store/item pair available on a given day
    """
    X = pd.DataFrame({  # Mean target for different retrospective timespans & total # promotions
        "mean_3_2017": get_timespan(cumul_sales, start_date, 3, 3).mean(axis=1).values,
        "mean_7_2017": get_timespan(cumul_sales, start_date, 7, 7).mean(axis=1).values,
        "mean_14_2017": get_timespan(cumul_sales, start_date, 14, 14).mean(axis=1).values,
        "promo_14_2017": get_timespan(promos, start_date, 14, 14).sum(axis=1).values
    })
    for i in range(FutureDaysToCalculate):  # Promotions on future days
        X["promo_{}".format(i)] = promos[
            start_date + timedelta(days=i)].values.astype(np.uint8)
    if is_train:
        y = cumul_sales[  # Target values for future days
            pd.date_range(start_date, periods=16)
        ].values
        return X, y
    return X

def create_machine_learning_matrices(cumul_sales, promos, start_date, current_date, test_start_date):
    print("Preparing dataset...")
    X_l, y_l = [], []
    for i in range(4):
        delta = timedelta(days=7 * i)
        X_tmp, y_tmp = prepare_dataset(
            cumul_sales,
            promos,
            start_date + delta
        )
        X_l.append(X_tmp)
        y_l.append(y_tmp)
    X_train = pd.concat(X_l, axis=0)
    y_train = np.concatenate(y_l, axis=0)
    del X_l, y_l
    X_val, y_val = prepare_dataset(cumul_sales, promos, test_start_date)
    X_test = prepare_dataset(cumul_sales, promos, current_date, is_train=False)

    return X_train, y_train, X_val, y_val, X_test


if __name__ == "__main__":
    (loc, min_date, cumul_sale_tbl, cumul_sale_future_tbl, items_tbl, stores_tbl) = sys.argv[1:]
    if loc == "csv":
        cumul_sales, cumul_sales_future, stores, items = \
            load_data_csv(cumul_sale_tbl, cumul_sale_future_tbl, items_tbl, stores_tbl)
    elif loc == "sql":
        raise ValueError ("Not implemented")
    else:
        raise ValueError ("First argument must be format: csv or sqls")

    (min_y, min_m, min_d) = min_date.split("-")
    cumul_sales = cumul_sales.loc[cumul_sales.date>=pd.datetime(int(min_y), int(min_m), int(min_d))]

    promo_variables = generate_promo_variables(cumul_sales, cumul_sales_future)
    cumul_sales     = generate_unit_sales_columns(cumul_sales)

    # Align the items info with our cumul sales info, so features can be extracted
    items = items.reindex(cumul_sales.index.get_level_values(1))

    now = datetime.now()
    #DEBUG DEBUG FIXME TODO Undo this
    now = date(2017, 8, 15)

    # How far back to go to start generating trend features for demand
    history_start = now - timedelta(7*WeeksOfHistoryForFeature) + timedelta(1)
    test_start    = now - timedelta(7*WeeksOfHistoryForFeatureOnTest) + timedelta(1)
    create_machine_learning_matrices(\
        cumul_sales, promo_variables, \
        start_date=history_start, current_date=now, test_start_date=test_start)




    # To be safe, we start about
