import cPickle as pickle
import csv
import pdb
from sklearn import cross_validation
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.svm import SVR
from sklearn.grid_search import GridSearchCV
import numpy as np
import random



if 'fdict' not in globals():  
  print 'fdict,targetdict not loaded. Loading them now.'
  fdict = pickle.load(open('../data/fdict.pkl','rb'))
  targetdict = pickle.load(open('../data/targetdict.pkl','rb'))
else:
  print 'fdict, targetdict already present. not loading the pickle files.'
  
target_train = []
feature_train = []
for k in targetdict: #Getting rid of NA.todo: move into get_features.py
  target_train.append(targetdict[k])
  temp = []
  for e in fdict[k]:
    if isinstance(e,str):
      temp.append(0)
    else:
      temp.append(e)
    
  feature_train.append(temp)
feature_train = np.asarray(feature_train)
target_train = np.asarray(target_train)
#p = range(len(target_train))
#random.seed(0)
#random.shuffle(p)
#feature_train, target_train = feature_train[p], target_train[p]



svr_rbf = SVR(kernel='rbf', C=1e3, gamma=0.1)
svr_lin = SVR(kernel='linear', C=1e3)
svr_poly = SVR(kernel='poly', C=1e3, degree=2)
y_rbf = svr_rbf.fit(feature_train, target_train).predict(feature_train)
y_lin = svr_lin.fit(feature_train, target_train).predict(feature_train)
y_poly = svr_poly.fit(feature_train, target_train).predict(feature_train)
# look at the results
plt.figure()
plt.scatter(y_rbf, target_train, c='k')
plt.title('rbf')
plt.figure()
plt.scatter(y_lin, target_train, c='k')
plt.title('lin')
plt.figure()
plt.scatter(y_poly, target_train, c='k')
plt.title('poly')
plt.legend()
plt.show()



#params = {'n_estimators': 500, 'max_depth': 4, 'min_samples_split': 1,
#          'learning_rate': 0.01, 'loss': 'ls'}
#classifier = GradientBoostingRegressor(**params)

'''
classifier = RandomForestRegressor(n_estimators=50,verbose=2,n_jobs=-1,min_samples_split=10,random_state=1)

kfold = cross_validation.KFold(len(target_train),n_folds=3)
n_estimVals = np.array([10,20,40,80,160,320,640])
scores = []
scores_std = []
for n_estimators in n_estimVals:
  classifier.n_estimators = n_estimators
  tempscores = cross_validation.cross_val_score(classifier, feature_train, target_train, cv=kfold, n_jobs=-1)
  scores.append(np.mean(tempscores))
  scores_std.append(np.std(tempscores))
print scores
print scores_std
[0.41042812750781171, 0.43276526323211822, 0.44195805735115162, 0.44592584463745827, 0.44791045572954546, 0.44888557453564198, 0.44968682496477247]
[0.0025235312634255993, 0.0041688583915200856, 0.0051462937715663357, 0.0055424090013091272, 0.0065087803045722993, 0.0065133311035727995, 0.0065203400078039939]

classifier.n_estimators = 20
kfold = cross_validation.KFold(len(target_train),n_folds=3)
min_samples_splitVals = np.array([200,1000,2000])
scores1 = []
scores1_std = []
for v in min_samples_splitVals:
  classifier.min_samples_split = v
  tempscores = cross_validation.cross_val_score(classifier, feature_train, target_train, cv=kfold, n_jobs=-1)
  scores1.append(np.mean(tempscores))
  scores1_std.append(np.std(tempscores))
print scores1
print scores1_std
#np.array([2,5,10,25,50,100])
#[0.41296657277424575, 0.42405330572526134, 0.43276526323211822, 0.43371539168546408, 0.42015215155311531, 0.3942947374789198]
#[0.0038690644579481826, 0.0034887469730057381, 0.0041688583915200856, 0.0027206249067935791, 0.0021123019275509944, 0.0024210997165072354]
#np.array([200,1000,2000])
#[0.35572257170475935, 0.27060682472975867, 0.23263357489543757]
#[0.0043409505279171775, 0.0029183961263162558, 0.0047074094007002075]
'''


classifier.fit(feature_train,target_train)
predicted_train = classifier.predict(feature_train)
#Pred vs true
plt.figure()
plt.scatter(target_train,classifier.predict(feature_train))
plt.plot([0, 100], [0, 100], '--k')
plt.axis('tight')
plt.xlabel('True count')
plt.ylabel('Predicted count')
plt.title('Insample MSE: %.4f, %d:%d' % (mean_squared_error(target_train,classifier.predict(feature_train)),classifier.n_estimators,classifier.min_sample_split))
'''
print("Saving the classifier")
pickle.dump(classifier, open('out_model.pkl', "wb"))

print("Writing features to file")
rows = [a+[b] for (a,b) in zip(features_train, target_train)]
writer = csv.writer(open('out_wekadata.csv', "wb"), lineterminator="\n")
writer.writerow(("feat1", "feat2", "feat3","feat4","feat5","target"))
writer.writerows(rows)
'''  
