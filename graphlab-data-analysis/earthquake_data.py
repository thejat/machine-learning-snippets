import urllib
import csv
import string
import pdb


#load the earthquake data from internet
csvgps = urllib.urlopen("http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.csv")
f = csvgps.read();
with open('csvgps.csv','w') as temp:
    temp.write(f)

reader = csv.reader(open("csvgps.csv"), delimiter=",")
upper_limit = min(20,len([0 for line in reader])-1)
data = [[0 for col in range(3)] for row in range(upper_limit)]
index = 0
reader = csv.reader(open("csvgps.csv"), delimiter=",")
for line in reader:
    if index > 0 and index <= upper_limit:
        data[index - 1][0] = float(line[1])
        data[index - 1][1] = float(line[2])
        data[index - 1][2] = float(line[4])
    index = index + 1
