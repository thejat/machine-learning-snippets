from collections import defaultdict
import cPickle as pickle
import csv
import pdb
    
    
  
print("Getting features for test reviews from rdict")
with open('../data/sample_submission.csv','rb') as fin:
  testlist = fin.read().split('\n')
  testlist.pop(-1)
  testlist = [x.split(',') for x in testlist]
  testlistheader = testlist[0]
  testlist.pop(0)

feature_test = []
for k in testlist:
  temp = []
  for e in fdict[k[0]]:
    if isinstance(e,str):
      temp.append(0)
    else:
      temp.append(e)
  feature_test.append(temp)

'''
print("Loading the classifier")
classifier = pickle.load(open('out_model.pkl','rb'))
'''

print("Making predictions")
predicted_test = classifier.predict(feature_test)

fw = open('../data/submission_theja.csv','wb')
fw.write(testlistheader[0]+','+testlistheader[1]+'\n')
for k,v in zip(testlist,predicted_test):
  fw.write(k[0]+','+str(v)+'\n')
fw.close()
