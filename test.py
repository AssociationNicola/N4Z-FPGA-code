#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
#import matplotlib
#matplotlib.use('TKAgg')
#from matplotlib import pyplot as plt
import os
import time

from n4z import Nicola4Z
from koheron import connect

host = os.getenv('HOST', '192.168.100.139')
client = connect(host, 'nicola4z')
driver = Nicola4Z(client)
time.sleep(1)
n = 32768
lcd_value=31 #as appropriate
display_value=31 #as appropriate

driver.set_led(2+8)
driver.reset_fifo()
time.sleep(1)
driver.set_led(4+8*2)
driver.set_lcd(lcd_value)
driver.set_display(display_value)

# # Dynamic plot
# fig = plt.figure()
# ax = fig.add_subplot(111)
# x = np.arange(n)
# y = np.zeros(n)
# li, = ax.plot(x, y)
# ax.set_ylim((-2**31, 2**31))
# fig.canvas.draw()


# while True:
    # try:
        # data = driver.read_adc()
        # print(driver.get_fifo_length())
        # li.set_ydata(data)
        # fig.canvas.draw()
        # plt.pause(0.001)
    # except KeyboardInterrupt:
        # break
