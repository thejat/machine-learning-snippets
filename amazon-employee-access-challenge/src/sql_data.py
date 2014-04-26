import MySQLdb 
import pandas as pd 
db = MySQLdb.connect(host="localhost", user="zzz", passwd="zzz") 
cur = db.cursor() 
cur.execute('DROP DATABASE IF EXISTS amazon') 
cur.execute('CREATE DATABASE amazon') 
cur.execute("USE amazon") 
cur.execute('''CREATE TABLE training (                     ACTION INT,                     RESOURCE INT,                     MGR_ID INT,                     ROLE_ROLLUP_1 INT,                     ROLE_ROLLUP_2 INT,                     ROLE_DEPTNAME INT,                     ROLE_TITLE INT,                     ROLE_FAMILY_DESC INT,                     ROLE_FAMILY INT,                     ROLE_CODE INT                 ) ''') 
cur.execute('''CREATE TABLE testing (                     id INT,                     RESOURCE INT,                     MGR_ID INT,                     ROLE_ROLLUP_1 INT,                     ROLE_ROLLUP_2 INT,                     ROLE_DEPTNAME INT,                     ROLE_TITLE INT,                     ROLE_FAMILY_DESC INT,                     ROLE_FAMILY INT,                     ROLE_CODE INT                 ) ''') 
train = pd.read_csv('train.csv') 
test = pd.read_csv('test.csv') 
train = train.as_matrix() 
test = test.as_matrix() 
for i in range(train.shape[0]):     
  cur.execute('INSERT INTO training VALUES (%s);' % ','.join(str(x) for x in train[i,:]))
for i in range(test.shape[0]):    
  cur.execute('INSERT INTO testing VALUES (%s);' % ','.join(str(x) for x in test[i,:])) 

db.commit() 
db.close()
