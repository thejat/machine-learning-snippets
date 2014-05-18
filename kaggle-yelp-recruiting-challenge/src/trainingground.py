


from sklearn import datasets, svm
digits = datasets.load_digits()
X_digits = digits.data
y_digits = digits.target
svc = svm.SVC(C=1, kernel='linear')
print svc.fit(X_digits[:-100], y_digits[:-100]).score(X_digits[-100:], y_digits[-100:])



import numpy as np
X_folds = np.array_split(X_digits, 3)
y_folds = np.array_split(y_digits, 3)
scores = list()
for k in range(3):
  # We use 'list' to copy, in order to 'pop' later on
  X_train = list(X_folds)
  X_test  = X_train.pop(k)
  X_train = np.concatenate(X_train)
  y_train = list(y_folds)
  y_test  = y_train.pop(k)
  y_train = np.concatenate(y_train)
  scores.append(svc.fit(X_train, y_train).score(X_test, y_test))
print scores


from sklearn import cross_validation
k_fold = cross_validation.KFold(n=6,n_folds=3,indices=True)
for train_indices,test_indices in k_fold:
  print 'Train: %s | test: %s' % (train_indices,test_indices)
  
  
kfold = cross_validation.KFold(len(X_digits),n_folds=6)
scores = [svc.fit(X_digits[train], y_digits[train]).score(X_digits[test], y_digits[test])
          for train, test in kfold]
print scores
print cross_validation.cross_val_score(svc, X_digits, y_digits, cv=kfold, n_jobs=-1)
stratkfold = cross_validation.StratifiedKFold(y_digits,n_folds=6)
print cross_validation.cross_val_score(svc, X_digits, y_digits, cv=stratkfold, n_jobs=-1)





import numpy as np
from sklearn import cross_validation, datasets, svm

digits = datasets.load_digits()
X = digits.data
y = digits.target

svc = svm.SVC(kernel='linear')
C_s = np.logspace(-10, 0, 10)

scores = list()
scores_std = list()
for C in C_s:
    svc.C = C
    this_scores = cross_validation.cross_val_score(svc, X, y, n_jobs=1)
    scores.append(np.mean(this_scores))
    scores_std.append(np.std(this_scores))

# Do the plotting
import pylab as pl
pl.figure(1, figsize=(4, 3))
pl.clf()
pl.semilogx(C_s, scores)
pl.semilogx(C_s, np.array(scores) + np.array(scores_std), 'b--')
pl.semilogx(C_s, np.array(scores) - np.array(scores_std), 'b--')
locs, labels = pl.yticks()
pl.yticks(locs, map(lambda x: "%g" % x, locs))
pl.ylabel('CV score')
pl.xlabel('Parameter C')
pl.ylim(0, 1.1)
pl.show()

from sklearn.grid_search import GridSearchCV
gammas = np.logspace(-6, -1, 10)
clf = GridSearchCV(estimator=svc, param_grid=dict(gamma=gammas),
                    n_jobs=-1)
clf.fit(X_digits[:1000], y_digits[:1000]) 
print clf.best_score_
print clf.best_estimator_.gamma
print clf.score(X_digits[1000:], y_digits[1000:])
