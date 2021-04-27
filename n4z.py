
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command, connect

class Nicola4Z(object):
    def __init__(self, client):
        self.client = client
        # self.n_pts = 16384
        self.n_pts = 1024
        self.fs = 2e5 # sampling frequency (Hz)
        self.control_val = 0

    @command()
    def get_fifo_occupancy(self):
        return self.client.recv_uint32()

    @command()
    def get_fifo_length(self):
        return self.client.recv_uint32()

    @command()
    def get_acquisition_status(self):
        return self.client.recv_uint32()

    @command()
    def reset_fifo(self):
        pass

    @command()
    def reset_tx_fifo(self):
        pass

    @command()
    def read_data(self):
        return self.client.recv_array(self.n_pts, dtype='int32', check_type=False)

    @command()
    def read_available_data(self):
        return self.client.recv_array(self.n_pts, dtype='int32', check_type=False)


    @command()
    def get_dna(self):
        return self.client.recv_uint64()


    @command()
    def get_tx_fifo_vacancy(self):
        return self.client.recv_uint32()


    @command()
    def xadc_read(self,channel):
        return self.client.recv_uint32()

    @command()
    def get_data(self):
        return self.client.recv_uint32()

    @command()
    def write_data(self,data):
        pass


    @command()
    def get_max_amplitude(self):
        return self.client.recv_uint32()

    @command()
    def get_average_amplitude(self):
        return self.client.recv_uint32()


    @command()
    def set_led(self, value):
        pass

    @command()
    def set_lcd(self, value):
        pass

    @command()
    def set_display(self, value):
        pass

    @command()
    def set_user_io(self, value):
        pass

    @command()
    def set_average(self, value):
        pass

    @command()
    def set_ssb_tx_frequency(self, value):
        pass

    @command()
    def set_control(self, value):
        self.control_val=value
        pass

    def set_DAC_out_val(self, value):
        value=(value&1) << 16
        self.control_val=self.control_val & (2**32 -1 -2**16)
        
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

    def set_data_fifo_in_val(self, value):
        value=(value&3) << 2
        self.control_val=self.control_val & (2**32 -1 -2**3 -2**2)      
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

    def set_FIR_in_val(self, value):
        value=(value&1) << 4

        self.control_val=self.control_val & (2**32 -1 -2**4)
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

#Note to go properly in to TX mode, need to set_FIR_in_val to 1 as well and return to zero to return to RX
#This just enables the ssb modulator)
    def set_TX_High(self, value):
        value=(value&1) << 1

        self.control_val=self.control_val & (2**32 -1 -2)
        self.control_val=self.control_val | value
        self.set_control(self.control_val)




    def get_control_val(self):
        return self.control_val



# Set DDS frequency within FPGA (used for LO )
    @command(classname="Dds")
    def set_dds_freq(self, freq):
        pass
