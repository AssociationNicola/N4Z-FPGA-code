#!/usr/bin/env python3
"""Play a sine signal."""
import argparse
import sys

import numpy as np
import os
import time
import sounddevice as sd



from n4z import Nicola4Z
from koheron import connect

def int_or_str(text):
    """Helper function for argument parsing."""
    try:
        return int(text)
    except ValueError:
        return text

ARRAY_SIZE=1024

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
    'frequency', nargs='?', metavar='FREQUENCY', type=float, default=500,
    help='frequency in Hz (default: %(default)s)')
parser.add_argument(
    '-d', '--device', type=int_or_str,
    help='output device (numeric ID or substring)')
parser.add_argument(
    '-a', '--amplitude', type=float, default=0.2,
    help='amplitude (default: %(default)s)')
args = parser.parse_args(remaining)



host = os.getenv('HOST', '127.0.0.1')
client = connect(host, name='nicola4z', restart=True)
driver = Nicola4Z(client)
time.sleep(1)
n = 32768
#Need to enter 1250 to get 80000 - as if phase_incr is being set 64 times too big
freq0=86950
driver.set_led(0)
print(driver.set_dds_freq(freq0))
driver.reset_fifo()
driver.set_control(1)  #1 for USB, 0 for LSB

sd.default.channels=1
sd.default.samplerate = 8000
sd.default.device = 'bluealsa'
sd.default.blocksize = ARRAY_SIZE    #Normally same as ARR_SIZE in n4z.hpp and n_pts in n4z.py - abig value increases overall latency!
Attenuation=2**27
try:
    samplerate = sd.query_devices(args.device, 'output')['default_samplerate']

    def callback(outdata, frames, time, status):
        if status:
            print(status, file=sys.stderr)
        
        global Attenuation
        outdata[:] = np.reshape(np.int32(driver.read_data()) ,(ARRAY_SIZE,1))/Attenuation #This should be normalised to be less than +/-1.0
        maxval= np.max(outdata)
        if maxval>0.7:
            Attenuation=Attenuation*1.5
            outdata[:]=outdata[:]/1.5
        elif maxval<0.2:
            Attenuation=Attenuation/1.2
            outdata[:]=outdata[:]*1.2
        print(np.std(outdata))
        print(np.mean(outdata))
        print(Attenuation)
        print()



    with sd.OutputStream(device=args.device, channels=1, callback=callback,
                         samplerate=8000):
        print('#' * 80)
        print('press Return to quit')
        print('#' * 80)
        input()
except KeyboardInterrupt:
    parser.exit('')
except Exception as e:
    parser.exit(type(e).__name__ + ': ' + str(e))