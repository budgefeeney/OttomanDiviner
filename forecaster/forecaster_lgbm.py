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
import json
import psycopg2

FutureDaysToCalculate=16
WeeksOfHistoryForFeature=8
WeeksOfHistoryForFeatureOnValidate=3
TrainingTimePeriodCount  = 4

def load_data_csv (cumul_sales_path, cumul_sales_query_path, items_path, stores_path):
    """
    Loads three datasets from the file-system in CSV format:

    cumul_sale_path is the cumulative sales data, should be the last 12 months
    cumul_sale_query_path enumerates the things to predict
    items is item data
    stores is store data
    """
    cumul_sales = pd.read_csv(
        cumul_sales_path,
        usecols=[1, 2, 3, 4, 5],
        dtype={'onpromotion': bool},
        converters={'unit_sales': lambda u: np.log1p(float(u)) if float(u) > 0 else 0},
        parse_dates=["date"]
    )

    if cumul_sales_query_path is not None:
        cumul_sales_query = pd.read_csv(
            cumul_sales_query_path,
            usecols=[0, 1, 2, 3, 4],
            dtype={'onpromotion': bool},
            parse_dates=["date"],
        )

    query_start_date = str(cumul_sales_query.iloc[0,1]).split(" ")[0]

    cumul_sales_query = cumul_sales_query.set_index(
        ['store_nbr', 'item_nbr', 'date']
    )

    items = pd.read_csv(
        items_tbl,
    ).set_index("item_nbr")

    stores = pd.read_csv(
        stores_tbl
    ).set_index("store_nbr")

    return cumul_sales, cumul_sales_query, query_start_date, items, stores

def load_data_sql (cumul_sales_path, cumul_sales_query_path, items_path, stores_path):
    """
    Loads three datasets from the file-system in CSV format:

    cumul_sale_path is the cumulative sales data, should be the last 12 months
    cumul_sale_query_path enumerates the things to predict
    items is item data
    stores is store data
    """
    with open('db.json') as f:
        conf = json.load(f)

    print (str(conf))

    conn_str = "host={} dbname={} user={} password={}".format(conf['host'], conf['database'], conf['user'], conf['passw'])

    conn = psycopg2.connect(conn_str)

    cumul_sales = pd.DataFrame()
    for chunk in pd.read_sql("select * from " + cumul_sales_path + " where date >  CURRENT_DATE - INTERVAL '6 months' order by date asc", con=conn, chunksize=100000):
        cumul_sales = cumul_sales.append(chunk)
        print ("Appending chunk to cumulative sales")
    cumul_sales.unit_sales.apply(lambda u: np.log1p(float(u)) if float(u) > 0 else 0)
    print ("Cumulative sales loaded")


    cumul_sales_query = pd.DataFrame()
    for chunk in pd.read_sql("select * from " + cumul_sales_query_path + " where date >  CURRENT_DATE  and date < CURRENT_DATE + INTERVAL '16 days' order by date asc", con=conn, chunksize=100000):
        print ("Appending chunk to sales query")
        cumul_sales_query = cumul_sales_query.append(chunk)

    query_start_date = str(cumul_sales_query.iloc[0,1]).split(" ")[0]
    cumul_sales_query = cumul_sales_query.set_index(
        ['store_nbr', 'item_nbr', 'date']
    )
    print ("Sales query loaded")

    items = pd.DataFrame()
    for chunk in pd.read_sql("select * from " + items_path, con=conn, chunksize=5000):
        print ("Appending chunk to items")
        items = items.append(chunk)
    print ("Items loaded")

    stores = pd.DataFrame()
    for chunk in pd.read_sql("select * from " + items_path, con=conn, chunksize=5000):
        print ("Appending chunk to stores")
        stores = stores.append(chunk)

    items = items.set_index("item_nbr")
    stores = stores.set_index("store_nbr")
    print ("Stores loaded")

    return cumul_sales, cumul_sales_query, query_start_date,  items, stores

def generate_promo_variables_train_and_query(cumul_sales, cumul_sales_query):
    """
    Generate a column for each of the next 16 days with 1 if there is a
    store-item pair for which a promotion exist on that day, and 0 otherwise.
    """
    promo_variables_train = cumul_sales.set_index(
        ["store_nbr", "item_nbr", "date"])[["onpromotion"]].unstack(
            level=-1).fillna(False)
    promo_variables_train.columns = promo_variables_train.columns.get_level_values(1)

    promo_variables_test = cumul_sales_query[["onpromotion"]].unstack(level=-1).fillna(False)
    promo_variables_test.columns = promo_variables_test.columns.get_level_values(1)
    promo_variables_test = promo_variables_test.reindex(promo_variables_train.index).fillna(False)

    promo_variables = pd.concat([promo_variables_train, promo_variables_test], axis=1)

    del promo_variables_train, promo_variables_test

    return promo_variables

def generate_unit_sales_columns(cumul_sales):
    """
    Rotate the dataset so it's not normalized any more, and is more pivot-table
    styled, with a column for each of the days.
    """

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

def create_machine_learning_matrices(cumul_sales, promos_train_and_query, start_date, current_date, test_start_date):
    """
    A dataset is trend prices over the last time-period.

    There are three training sets:

    train    - for training the model
    validate - a subset of the training data for validating the model, so we
    know when to stop Training
    query    - the bit to actually predict.

    While the feature extraction is for the last 2 weeks, there's nothing to stop
    us repeating this process for other time periods, to accumulate more data.
    The features are independent of the *actual* time, we're just predicting
    future prices given the previous prices.

    You'll note there are no cumul_sales_query parameter, this is because the
    necessary data is in the promos_train_and_query field, which lists, for
    every date, store and item whether the item is on promotion or not.
    """

    print("Preparing dataset...")
    X_l, y_l = [], []
    for i in range(TrainingTimePeriodCount):
        delta = timedelta(days=7 * i)
        X_tmp, y_tmp = prepare_dataset(
            cumul_sales,
            promos_train_and_query,
            start_date + delta
        )
        X_l.append(X_tmp)
        y_l.append(y_tmp)
    X_train = pd.concat(X_l, axis=0)
    y_train = np.concatenate(y_l, axis=0)
    del X_l, y_l

    X_validate, y_validate = prepare_dataset(cumul_sales, promos_train_and_query, test_start_date)

    X_query = prepare_dataset(cumul_sales, promos_train_and_query, current_date, is_train=False)

    return X_train, y_train, X_validate, y_validate, X_query

def train_model(items, X_train, y_train, X_validate, y_val, X_test, params=None, maxRounds=5000):
    """
    Train a model using Lightwave Gradient Boosted Methods, specifically a
    gradient-boosted regression-tree.

    Optimise the L2 norm of the MSE.
    """

    if params is None:
        params = {
            'num_leaves': 2**5 - 1,
            'objective': 'regression_l2',
            'max_depth': 8,
            'min_data_in_leaf': 50,
            'learning_rate': 0.05,
            'feature_fraction': 0.75,
            'bagging_fraction': 0.75,
            'bagging_freq': 1,
            'metric': 'l2',
            'num_threads': 4
        }
    validate_pred = []
    query_pred = []
    cate_vars = []
    for i in range(FutureDaysToCalculate):
        print("=" * 50)
        print("Future Day %d" % (i+1))
        print("=" * 50)
        dtrain = lgb.Dataset(
            X_train, label=y_train[:, i],
            categorical_feature=cate_vars,
            weight=pd.concat([items["perishable"]] * 4) * 0.25 + 1
        )
        dval = lgb.Dataset(
            X_validate, label=y_val[:, i], reference=dtrain,
            weight=items["perishable"] * 0.25 + 1,
            categorical_feature=cate_vars)
        bst = lgb.train(
            params, dtrain, num_boost_round=maxRounds,
            valid_sets=[dtrain, dval], early_stopping_rounds=50, verbose_eval=50
        )
        print("\n".join(("%s: %.2f" % x) for x in sorted(
            zip(X_train.columns, bst.feature_importance("gain")),
            key=lambda x: x[1], reverse=True
        )))
        validate_pred.append(bst.predict(
            X_validate, num_iteration=bst.best_iteration or maxRounds))
        query_pred.append(bst.predict(
            X_test, num_iteration=bst.best_iteration or maxRounds))

    validate_rmse = np.sqrt (mean_squared_error(np.expm1(y_validate), np.expm1(np.array(validate_pred)).transpose()))

    return query_pred, validate_rmse

def save_predictions(cumul_sales, cumul_sales_query, query_start_date, query_predictions, output_file):
    """
    Save the predictions. The output matches the cumul_sales input, except it
    does not have promotions included
    """

    print("Saving predictions...")
    y_query = np.array(query_pred).transpose()
    df_preds = pd.DataFrame(
        y_query, index=cumul_sales.index,
        columns=pd.date_range(query_start_date, periods=16)
    ).stack().to_frame("unit_sales")
    df_preds.to_csv(output_file)

def save_predictions_sql(cumul_sales, cumul_sales_query, query_start_date, query_predictions, output_file):
    """
    Save the predictions. The output matches the cumul_sales input, except it
    does not have promotions included
    """

    print("Saving predictions...")
    y_query = np.array(query_pred).transpose()
    df_preds = pd.DataFrame(
        y_query, index=cumul_sales.index,
        columns=pd.date_range(query_start_date, periods=16)
    ).stack().to_frame("unit_sales")
    df_preds.to_sql(output_file)


if __name__ == "__main__":
    (loc, min_date, cumul_sale_tbl, cumul_sale_future_tbl, items_tbl, stores_tbl, output_tbl) = sys.argv[1:]
    if loc == "csv":
        cumul_sales, cumul_sales_query, query_start_date, items, stores = \
            load_data_csv(cumul_sale_tbl, cumul_sale_future_tbl, items_tbl, stores_tbl)
    elif loc == "sql":
        cumul_sales, cumul_sales_query, query_start_date, items, stores = \
            load_data_sql(cumul_sale_tbl, cumul_sale_future_tbl, items_tbl, stores_tbl)
    else:
        raise ValueError ("First argument must be format: csv or sqls")

    (min_y, min_m, min_d) = min_date.split("-")
    cumul_sales = cumul_sales.loc[cumul_sales.date>=pd.datetime(int(min_y), int(min_m), int(min_d))]

    promo_variables = generate_promo_variables_train_and_query(cumul_sales, cumul_sales_query)
    cumul_sales     = generate_unit_sales_columns(cumul_sales)

    # Align the items info with our cumul sales info, so features can be extracted
    items = items.reindex(cumul_sales.index.get_level_values(1))

    now = datetime.now()
    # #DEBUG DEBUG FIXME TODO Undo this
    # now = date(2017, 8, 15)

    # How far back to go to start generating trend features for demand
    history_start = now - timedelta(7*WeeksOfHistoryForFeature) + timedelta(1)
    test_start    = now - timedelta(7*WeeksOfHistoryForFeatureOnValidate) + timedelta(1)
    X_train, y_train, X_validate, y_validate, X_query = create_machine_learning_matrices(\
        cumul_sales, promo_variables, \
        start_date=history_start, current_date=now, test_start_date=test_start)

    # Train a separate model for each of the next `FutureDaysToCalculate`
    query_pred, validate_rmse = train_model(items, X_train, y_train, X_validate, y_validate, X_query)
    print ("Validation error is : " + str(validate_rmse))

    save_predictions(cumul_sales, cumul_sales_query, query_start_date, query_pred, output_tbl)
