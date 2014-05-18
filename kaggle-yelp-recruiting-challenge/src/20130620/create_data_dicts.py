import pdb
import datetime
import cPickle as pickle

def get_data(prefix):
  userdataheaders = get_data_core(prefix+'user.csv')
  businessdataheaders = get_data_core(prefix+'business.csv')
  checkindataheaders = get_data_core(prefix+'checkin.csv')
  reviewdataheaders = get_data_core(prefix+'review.csv')
  
  userdata = userdataheaders[0]
  userheaders = userdataheaders[1]
  businessdata = businessdataheaders[0]
  businessheaders = businessdataheaders[1]
  checkindata = checkindataheaders[0]
  checkinheaders = checkindataheaders[1]
  reviewdata = reviewdataheaders[0]
  reviewheaders = reviewdataheaders[1]

  return [userdata,businessdata,checkindata,reviewdata,userheaders,
          businessheaders,checkinheaders,reviewheaders]

def get_data_core(filepath):
  with open(filepath,'rb') as fin:
    data = fin.read().split('\n')
    headers = data[0].split(',')
    data.pop(0)
    data.pop(-1)
    data = [x.split(',') for x in data]
  return [data,headers]

trainprefix = '../data/yelp_training_set/'
trainprefix = trainprefix + 'yelp_training_set_'
traindata = get_data(trainprefix)
#[userdata,businessdata,checkindata,reviewdata,userheaders,
#          businessheaders,checkinheaders,reviewheaders]
testprefix = '../data/yelp_test_set/'
testprefix = testprefix + 'yelp_test_set_'
testdata = get_data(testprefix)

ntrain = len(traindata[3])
targetdict = dict((x[2],float(x[-1])) for x in traindata[3])
pickle.dump(targetdict,open('../data/targetdict.pkl','wb'))


userdata = [x[:5] for x in traindata[0]] + testdata[0]
businessdata = traindata[1] + testdata[1]
reviewdata = [x[:7] for x in traindata[3]] + testdata[3]

udict = {}
bdict = {}
rdict = {}
for e in userdata:
  udict[e[4]] = e
for e in businessdata:
  bdict[e[0]] = e
for e in reviewdata:
  rdict[e[2]] = e

pickle.dump(udict,open('../data/udict.pkl','wb'))
pickle.dump(bdict,open('../data/bdict.pkl','wb'))
pickle.dump(rdict,open('../data/rdict.pkl','wb'))
pickle.dump(traindata[4:],open('../data/headers.pkl','wb'))

