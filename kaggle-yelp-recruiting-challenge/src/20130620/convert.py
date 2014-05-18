'''
Convert Yelp Academic Dataset from JSON to CSV

Requires Pandas (https://pypi.python.org/pypi/pandas)

By Paul Butler, No Rights Reserved
'''

import json
import pandas as pd
from glob import glob
import pdb

def filtern(str1):
  return str1.replace('\n',' ').replace('\r\n',' ').replace('\\n',' ').replace('\'','').replace(',',' ')
	
def main():
  for json_filename in glob('*.json'):
    csv_filename = '%s.csv' % json_filename[:-5]
    print 'Converting %s to %s' % (json_filename, csv_filename)
    temp = []
    for x in file(json_filename):
      ob = json.loads(x)
      for k, v in ob.items():
        if isinstance(v, list):
          ob[k] = ':'.join(v)
        elif isinstance(v, dict):
          for kk, vv in v.items():
            ob['%s_%s' % (k, kk)] = vv
          del ob[k]
      for i in ob:
        if isinstance(ob[i],int) or isinstance(ob[i],float):
          a = 1
        else:
          #print ob[i]
          ob[i] = filtern(ob[i])
          #print ob[i]
      temp.append(ob)
    #pdb.set_trace()
    df = pd.DataFrame(temp)
    df.to_csv(csv_filename, encoding='utf-8', index=False)
    
if __name__=='__main__':
  main()
