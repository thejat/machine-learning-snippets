#!/usr/env python

#example from http://austingwalters.com/introduction-to-markov-processes/

import numpy as np

def Markov(p, s, steps):
    for i in range(steps):
        s = s * p
    return s

p = np.matrix('.5, .5, 0, 0, 0, 0; .4, .1, .5, 0, 0, 0; 0, .3, .2, .5, 0, 0; 0, 0, .2, .3, .5, 0; 0, 0, 0, .1, .4, .5; 0, 0, 0, 0, 0, 1')
s = np.matrix('1, 0, 0, 0, 0, 0')
steps = 10
print(Markov(p, s, steps))


