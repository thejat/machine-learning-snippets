import numpy as np
import pandas as pd

with open("../kaggle-amazon/p_sub.txt.linear",'rb') as f:
  data1 = f.read().replace('\r','').split('\n')
  data1.pop(-1)
  data1.pop(0)
with open("../kaggle-amazon/p_sub.txt.nonlinear",'rb') as f:
  data2 = f.read().replace('\r','').split('\n')
  data2.pop(-1)
  data2.pop(0)
with open("../paul_miroslav/paul_pred.csv",'rb') as f:
  data3 = f.read().split('\n')
  data3.pop(-1)
  data3.pop(0)
with open("../paul_miroslav/miroslav_pred.csv",'rb') as f:
  data4 = f.read().split('\n')
  header = data4[0].split(',')
  data4.pop(0)
  
data1 = [x.split(',') for x in data1]
data2 = [x.split(',') for x in data2]
data3 = [x.split(',') for x in data3]
data4 = [x.split(',') for x in data4]

data = np.array([[float(x[0][1]),float(x[1][1]),float(x[2][1]),float(x[3][1])] for x in zip(data1,data2,data3,data4)])

df = pd.DataFrame(data,columns=['1','2','3','4'])
df = df - df.mean(axis=0)
df = df/df.std()

pred_lin_comb = df['1'] + df['2'] + df['3'] + df['4']

with open('lin_comb_pred.csv','wb') as f:
  f.write(','.join(header)+'\n')
  for i,x in enumerate(pred_lin_comb):
    f.write(str(i+1) + ',' + str(x)+'\n')









