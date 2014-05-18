import cPickle as pickle
import csv
import pdb
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import GradientBoostingRegressor

if 'fdict' not in locals():  
  print 'fdict,targetdict not loaded. Loading them now.'
  fdict = pickle.load(open('../data/fdict.pkl','rb'))
  targetdict = pickle.load(open('../data/targetdict.pkl','rb'))
else:
  print 'fdict, targetdict already present. not loading the pickle files.'
  
target_train = []
feature_train = []
for k in targetdict:
  target_train.append(targetdict[k])
  temp = []
  for e in fdict[k]:
    if isinstance(e,str):
      temp.append(0)
    else:
      temp.append(e)
    
  feature_train.append(temp)

  '''
  features = [[1],[3],[5],[7],[9]]
  target = [0,0,0,1,1]
  '''
# Fit regression model
params = {'n_estimators': 500, 'max_depth': 4, 'min_samples_split': 1,
          'learning_rate': 0.01, 'loss': 'ls'}
#classifier = GradientBoostingRegressor(**params)
classifier = RandomForestRegressor(n_estimators=50,verbose=2,n_jobs=1,min_samples_split=10,random_state=1)
classifier.fit(feature_train,target_train)
predicted_train = classifier.predict(feature_train)
mse = mean_squared_error(target_train,predicted_train)
print("Insample MSE: %.4f" % mse)
#Pred vs true
plt.scatter(target_train,predicted_train)
plt.plot([0, 100], [0, 100], '--k')
plt.axis('tight')
plt.xlabel('True count')
plt.ylabel('Predicted count')


print("Saving the classifier")
pickle.dump(classifier, open('out_model.pkl', "wb"))

'''
print("Writing features to file")
rows = [a+[b] for (a,b) in zip(features_train, target_train)]
writer = csv.writer(open('out_wekadata.csv', "wb"), lineterminator="\n")
writer.writerow(("feat1", "feat2", "feat3","feat4","feat5","target"))
writer.writerows(rows)
'''  
