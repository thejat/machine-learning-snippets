Yelp Recruiting Challenge code

Data directory is ../data/yelp_training_set/ and ../data/yelp_test_set/ where you put the *.json files.


Then execure the python scripts in the following order:
convert.py to convert from json to csv
create_data_dicts.py to create dictionary objects of the dataset
get_features.py to create some features
train.py to create a supervised learning model
predict.py to make prediction in the kaggle format
