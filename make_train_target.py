"""
This file creates training data set.
"""

import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin


class MakeTarget(BaseEstimator, TransformerMixin):

    def __init__(self, start, end, time_col, segment_col, agg_col):
        self.start = start
        self.end = end
        self.time_col=time_col
        self.segment_col = segment_col
        self.agg_col = agg_col

    def fit(self, X, y=None):
        return self

    def transform(self, X, y=None):
        train_df = X.set_index(self.time_col)
        train_df = train_df.groupby([pd.Grouper(freq='H'), self.segment_col])[self.agg_col].count()
        # make into bool
        train_df = train_df >= 1
        # get daterange
        date_range = pd.date_range(self.start, self.end, freq='H')
        # fill in data
        out_df = train_df.reset_index().groupby(self.segment_col).apply(reindex, date_range=date_range)
        return out_df


def reindex(df, date_range):
    return df.reindex(date_range, fill_value=0)


if __name__ == '__main__':
    train_path = 'data/train.csv'
    train_df = pd.read_csv(train_path)
    # make col datetime
    train_df['Occurrence Local Date Time'] = pd.to_datetime(train_df['Occurrence Local Date Time'])
    # init transformer
    make_target = MakeTarget('2016-01-01', '2019-01-01', 'Occurrence Local Date Time',
                                                                                       'road_segment_id', 'EventId')
    target = make_target.fit_transform(train_df)
    target.to_csv('train_target.csv')
