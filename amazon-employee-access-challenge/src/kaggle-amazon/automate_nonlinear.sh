python csv2vw.py ../../data/train.csv ../../data/train.vw
python csv2vw.py ../../data/test.csv ../../data/test.vw
vw -d ../../data/train.vw -k -c -f model --loss_function logistic -b 25 --passes 20 -q ee --l2 0.0000005
vw -t -d ../../data/test.vw -i model -p p.txt
python vw2sub.py p.txt p_sub.txt.nonlinear


