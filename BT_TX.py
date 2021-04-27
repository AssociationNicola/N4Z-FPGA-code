#!/usr/bin/env python3
"""Create a recording with arbitrary duration.

The soundfile module (https://PySoundFile.readthedocs.io/) has to be installed!

"""
import argparse
import sys
import os
import time
import queue
import sounddevice as sd
import numpy as np  # Make sure NumPy is loaded before it is used in the callback

from n4z import Nicola4Z
from koheron import connect


def int_or_str(text):
    """Helper function for argument parsing."""
    try:
        return int(text)
    except ValueError:
        return text


parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    '-l', '--list-devices', action='store_true',
    help='show list of audio devices and exit')
args, remaining = parser.parse_known_args()
if args.list_devices:
    print(sd.query_devices())
    parser.exit(0)
parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    parents=[parser])
parser.add_argument(
    'filename', nargs='?', metavar='FILENAME',
    help='audio file to store recording to')
parser.add_argument(
    '-d', '--device', type=int_or_str,
    help='input device (numeric ID or substring)')
parser.add_argument(
    '-r', '--samplerate', type=int, help='sampling rate')
parser.add_argument(
    '-c', '--channels', type=int, default=1, help='number of input channels')
parser.add_argument(
    '-t', '--subtype', type=str, help='sound file subtype (e.g. "PCM_24")')
args = parser.parse_args(remaining)

host = os.getenv('HOST', '127.0.0.1')
client = connect(host, name='nicola4z', restart=True)
driver = Nicola4Z(client)
time.sleep(1)
n = 32768

freq0=86950
ARRAY_SIZE=1024
mic_boost=5e9

driver.set_led(2+8*4)
print(driver.set_dds_freq(freq0))
driver.reset_fifo()
driver.reset_tx_fifo()
driver.set_control(0)  #1 for USB, 0 for LSB
driver.set_TX_Mode()
driver.set_data_fifo_in_val(1)

freq=87000

freqval=np.int32(freq * 2**24/8.192e6)
driver.set_ssb_tx_frequency(freqval)

sd.default.channels=1
sd.default.samplerate = 40000
sd.default.device = 'bluealsa'
sd.default.blocksize = ARRAY_SIZE    #Normally same as ARR_SIZE in n4z.hpp and n_pts in n4z.py - abig value increases overall latency!
q = queue.Queue()

print()
print('control value is: ',driver.get_control_val())
print()
def callback(indata, frames, time, status):
    """This is called (from a separate thread) for each audio block."""
    if status:
        print(status, file=sys.stderr)
    global mic_boost
    a=indata.copy()*mic_boost
    maxval= np.max(a)
    print(maxval)
    minval= np.min(a)
    print(minval)

    if maxval>2**31:
        mic_boost=mic_boost/1.5
        a[:]=a[:]*1.5
    elif maxval<2**29:
        mic_boost=mic_boost*1.2
        a[:]=a[:]/1.2
    q.put(np.int32(a))







try:

    # Make sure the file is opened before recording anything:
    with sd.InputStream(samplerate=40000, device='bluealsa',
                        channels=1, callback=callback):
        print('#' * 80)
        print('press Ctrl+C to stop the TX')
        print('#' * 80)
        while True:
            if (driver.get_tx_fifo_vacancy()>1030):
                driver.write_data(q.get())
            print('TX fifo vacancy: ',driver.get_tx_fifo_vacancy())
            #print('Max values: ',driver.get_max_amplitude())
            #print('Average values: ',driver.get_average_amplitude())

except KeyboardInterrupt:

    parser.exit(0)
except Exception as e:
    driver.set_RX_Mode()
    parser.exit(type(e).__name__ + ': ' + str(e))
