import pdb
import datetime
import cPickle as pickle

def datedelta(latest,rdict,fdict):
  for k,x in rdict.items():
    temp = [int(y) for y in x[1].split('-')]
    fdict[k].append((latest - datetime.datetime(temp[0],temp[1],temp[2],0,0)).total_seconds() / (60*60*24))
  return fdict

def feat_stars_counts(rdict,bdict,udict,fdict):
  for k,x in rdict.items():
    fdict[k].append(float(x[3]))
    if x[0] in bdict:
      #star and review count
      fdict[k].extend([float(bdict[x[0]][10]), float(bdict[x[0]][9])])
    else:
      fdict[k].append(['NA','NA'])
    if x[6] in udict:
      #average star and review count
      fdict[k].extend([float(udict[x[6]][0]),float(udict[x[6]][2])])
    else:
      fdict[k].extend(['NA','NA'])
  return fdict


#Read the stored data dicts
if 'udict' not in locals():
  print 'udict,bdict,rdict,headers not loaded. loading them now.'
  udict = pickle.load(open('../data/udict.pkl','rb'))
  bdict = pickle.load(open('../data/bdict.pkl','rb'))
  rdict = pickle.load(open('../data/rdict.pkl','rb'))
  headers = pickle.load(open('../data/headers.pkl','rb'))
else:
  print 'Dict udict, bdict and rdict already present in workspace'


fdict = {}
for i in rdict:
  fdict[i] = []

#timedelta isn days
train_snapshot = datetime.datetime(2013,01,19,0,0)
fdict = datedelta(train_snapshot,rdict,fdict)
#rstars, bstars, b rev counts, ustars, u rev counts
fdict = feat_stars_counts(rdict,bdict,udict,fdict)

pickle.dump(fdict,open('../data/fdict.pkl','wb'))
