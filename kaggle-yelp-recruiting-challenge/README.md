Yelp Recruiting Challenge code

Data directory is ../data/yelp_training_set/ and ../data/yelp_test_set/ where you put the *.json files.

Working src directory is ./src/20130620/

Copy the train.py from the above directory to ./src directory first.

Then execure the python scripts in the ./src directory n the following order:

convert.py to convert from json to csv

create_data_dicts.py to create dictionary objects of the dataset

get_features.py to create some features

train.py to create a supervised learning model

predict.py to make prediction in the kaggle format


disclaimer: Some parts of the code is reproduced from the sklearn examples and other places.
