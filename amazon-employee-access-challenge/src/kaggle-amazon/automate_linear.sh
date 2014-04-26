python csv2vw.py ../../data/train.csv ../../data/train.vw
python csv2vw.py ../../data/test.csv ../../data/test.vw
vw -d ../../data/train.vw -c -k -f model --loss_function logistic --passes 10
vw -t -d ../../data/test.vw -i model -p p.txt
python vw2sub.py p.txt p_sub.txt.linear


