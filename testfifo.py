#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib
matplotlib.use('TKAgg')
from matplotlib import pyplot as plt
import os
import time

from n4z import Nicola4Z
from koheron import connect

host = os.getenv('HOST', '192.168.100.141')
client = connect(host, 'nicola4z')
driver = Nicola4Z(client)

n = 32768
print('Starting N4Z test')
driver.reset_fifo()
# Dynamic plot
fig = plt.figure()
ax = fig.add_subplot(111)
x = np.arange(n)
y = np.zeros(n)
li, = ax.plot(x, y)
ax.set_ylim((-2**31, 2**31))
fig.canvas.draw()
#print('Fifo length is ',driver.get_fifo_length())

# while True:
    # try:
        # data = driver.read_adc()
        # print(driver.get_fifo_length())
        # li.set_ydata(data)
        # fig.canvas.draw()
        # plt.pause(0.001)
    # except KeyboardInterrupt:
        # break
