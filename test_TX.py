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

host = os.getenv('HOST', '192.168.100.140')
client = connect(host, 'nicola4z')
driver = Nicola4Z(client)
time.sleep(1)
n = 32768
ARRAY_SIZE=1024

driver.set_led(8+3)
driver.set_control(2) #to enable ssb modulator
sineblock=np.int32(2**22*np.sin(np.pi*np.arange(1024)/128))
driver.reset_tx_fifo()
print('first write')
print('Vacancy before write 1: ',driver.get_tx_fifo_vacancy())

driver.write_data(sineblock)
print('Vacancy after write 1: ',driver.get_tx_fifo_vacancy())
time.sleep(0.1)
#driver.reset_tx_fifo()
print('second write')
driver.write_data(sineblock)
print('Vacancy after write 2 without  a reset!: ',driver.get_tx_fifo_vacancy())

time.sleep(0.1)
print('Vacancy after write 2 without  a reset, but waiting 100ms: ',driver.get_tx_fifo_vacancy())

#driver.reset_tx_fifo()

print('doing third write')

driver.write_data(sineblock)
time.sleep(0.1)

print('Vacancy after write 3 without  a reset, but waiting 100ms: ',driver.get_tx_fifo_vacancy())

#driver.reset_tx_fifo()
print('fourth write')
driver.write_data(sineblock)

time.sleep(0.1)
print('Vacancy after write 4 without  a reset, but waiting 100ms: ',driver.get_tx_fifo_vacancy())

# # Dynamic plot
# fig = plt.figure()
# ax = fig.add_subplot(111)
# x = np.arange(n)
# y = np.zeros(n)
# li, = ax.plot(x, y)
# ax.set_ylim((-2**31, 2**31))
# fig.canvas.draw()
print('control val is before setting data FIR input: ',driver.get_control_val())

driver.set_FIR_in_val(1) #value of 1 send values from the tx fifo into the fir (and ultimately into the data_fifo)

print('control val is after setting data FIR input: ',driver.get_control_val())
#driver.reset_tx_fifo()

time.sleep(0.5)
driver.reset_fifo() #this should clear the data fifo

driver.write_data(sineblock)
while driver.get_tx_fifo_vacancy()<1030:
    pass
driver.write_data(sineblock)
while driver.get_tx_fifo_vacancy()<1030:
    pass
driver.write_data(sineblock)
while driver.get_tx_fifo_vacancy()<1030:
    pass
driver.write_data(sineblock)
while driver.get_tx_fifo_vacancy()<1030:
    pass
driver.write_data(sineblock)
while driver.get_tx_fifo_vacancy()<1030:
    pass

driver.write_data(sineblock)
print('length before reading: ',driver.get_fifo_length())

a=np.reshape(np.int32(driver.read_data()) ,(ARRAY_SIZE,1))
print('length after reading: ',driver.get_fifo_length())

plt.figure(1)
plt.plot(a)
driver.set_TX_High(1)
print('control val is after setting TX_High (should just enable SSB modulator!): ',driver.get_control_val())
driver.set_DAC_out_val(0)
driver.set_user_io(2**13)
plt.show()
driver.set_TX_High(0)

# while True:
    # try:
        # data = driver.read_adc()
        # print(driver.get_fifo_length())
        # li.set_ydata(data)
        # fig.canvas.draw()
        # plt.pause(0.001)
    # except KeyboardInterrupt:
        # break
