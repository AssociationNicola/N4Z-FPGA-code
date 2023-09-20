#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command, connect


# Recover data from BRAMS in 2 steps:
#Read data to a class value and then load the value recovered, eg:
#	driver.get_SecondBRAM()
#	BRAMcontents=driver.SecondBRAM


class Nicola4Z(object):
    def __init__(self, client):
        self.client = client
        # self.n_pts = 16384
        self.n_pts = 1200
        self.fs = 2e5 # sampling frequency (Hz)
        self.control_val = 0
        self.SecondBRAM_size = self.get_SecondBRAM_size()
        self.SecondBRAM = np.zeros((1, self.SecondBRAM_size))
        self.IQBRAM_size = self.get_IQBRAM_size()
        self.IQBRAM = np.zeros((1, self.IQBRAM_size))


    @command()
    def get_SecondBRAM_size(self):
        return self.client.recv_uint32()

    @command()
    def get_SecondBRAM(self):
        self.SecondBRAM = self.client.recv_array(self.SecondBRAM_size, dtype='int32')

    @command()
    def get_IQBRAM_size(self):
        return self.client.recv_uint32()

    @command()
    def get_IQBRAM(self):
        self.IQBRAM = self.client.recv_array(self.IQBRAM_size, dtype='int32')


#For this to send data to the IQBRAM, the 32 bit data needs to be pre-loaded into eg driver.IQdata numpy array
    def set_IQBRAM(self):
        @command()
        def set_IQBRAM_data(self, data):
            pass
        set_IQBRAM_data(self, self.IQBRAM)


    @command()
    def get_fifo_occupancy(self):
        return self.client.recv_uint32()

    @command()
    def get_fifo_length(self):
        return self.client.recv_uint32()

    @command()
    def get_status(self):
        return self.client.recv_uint32()

    @command()
    def reset_fifo(self):
        pass

    @command()
    def reset_tx_fifo(self):
        pass

    @command()
    def get_tx_fifo_vacancy(self):
        return self.client.recv_uint32()

    @command()
    def get_tx_fifo_occupancy(self):
        return self.client.recv_uint32()

    @command()
    def read_data(self):
        return self.client.recv_array(self.n_pts, dtype='int32', check_type=False)

    @command()
    def read_24_data(self):
        return self.client.recv_array(24, dtype='int32', check_type=False)

    @command()
    def read_available_data(self):
        return self.client.recv_array(self.n_pts, dtype='int32', check_type=False)


    @command()
    def get_dna(self):
        return self.client.recv_uint64()



    @command()
    def xadc_read(self,channel):
        return self.client.recv_uint32()

    @command()
    def get_battery_level(self):
        return self.client.recv_float()

    @command()
    def get_antenna_current(self):
        return self.client.recv_float()


    @command()
    def get_data(self):
        return self.client.recv_uint32()

    @command()
    def get_pd(self):
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
    def get_average_mult(self):
        return self.client.recv_uint32()

    @command()
    def get_msf_average_mult(self):
        return self.client.recv_uint32()

    @command()
    def get_msf_average_amplitude(self):
        return self.client.recv_uint32()


    @command()
    def get_msf_i(self):
        return self.client.recv_uint32()

    @command()
    def get_msf_q(self):
        return self.client.recv_uint32()

    @command()
    def get_msf_carrier_counter(self):
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
    def set_volume(self, value):
        pass

    @command()
    def set_agc_value(self, value):
        pass

    @command()
    def set_mult_agc_value(self, value):
        pass

    @command()
    def set_msf_agc_value(self, value):
        pass

#This sets the integer value of the msf frequency so will for example be exactly 77500 for Frankfurt
    @command()
    def set_msf_frequency(self, value):
        pass

    @command()
    def set_msf_low_time(self, value):
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


#Control bits: 0: (select USB),
# 1: enable SSB output,
#[2:3] select data for data fifo (RX): 0 SSB receive and SSB(cordic) amp, 1 Freq and SSB amp, 2 I+Q after FIR agc, 3 I+Q after CIC agc
#4 select input to FIRs: 0 from CIC agcs, 1 from ARM TX fifo (only top 16 bits)
#5 select input to CICs: 0 from ADC 0 and downconvertor (set by local oscillator), 1 from ADC 1 (Mic input)
    @command()
    def set_control(self, value):
        self.control_val=value
        pass

    def set_DAC_out_val(self, value):
        value=(value&1) << 16
        self.control_val=self.control_val & (2**32 -1 -2**16)
        
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

#data fifo in options:  0 SSB receive and SSB(cordic) amp, 1 Freq and SSB amp, 2 I+Q after FIR agc, 3 I+Q after CIC agc, 4 raw ADC (ignore lowest 16 bits), 5  I+Q DDS, 6  I+Q after the multiplier (before cic), 7 I+Q after CIC agc
#now includes an extra bit to add 4 further test option 4-7 (7 is a repeat of 3 but with a different trigger) - uses bits: 2,3,7 of control register
    def set_data_fifo_in_val(self, fvalue):
        value=(fvalue&3) << 2
        ext=(fvalue&4) << 5    #selects options 4-7
        self.control_val=self.control_val & (2**32 -1 -2**3 -2**2)      #resets bits 3 and 2
        self.control_val=self.control_val | value
        self.control_val=self.control_val & (2**32 -1 -2**7)            #resets bit 7
        self.control_val=self.control_val | ext
        self.set_control(self.control_val)

    def set_FIR_in_val(self, value):
        value=(value&1) << 4

        self.control_val=self.control_val & (2**32 -1 -2**4)
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

#Note to go properly in to TX mode, need to set_FIR_in_val to 1 as well and return to zero to return to RX
#This just enables the ssb modulator (bit 1)
    def set_TX_High(self, value):
        value=(value&1) << 1

        self.control_val=self.control_val & (2**32 -1 -2)
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

#Sets side band 0=LSB, 1=USB
    def set_SSB(self, value):
        value=(value&1)

        self.control_val=self.control_val & (2**32 -1 -1)
        self.control_val=self.control_val | value
        self.set_control(self.control_val)

#This sets what goes to the CIC
#Sets state of bit 5 according to value (0 for antenna ADC and 1 for mic ADC)
    def set_Mic_In(self,value):
        value=(value&1) << 5

        self.control_val=self.control_val & (2**32 -1-2**5)  #first reset the bit in question
        self.control_val=self.control_val | value	  #then set them	
        self.set_control(self.control_val)

#This sets TX modulator to fixed amplitude for QPSK
#Sets state of bit 6 according to value (0 for normal and 1 for QPSK modulation)
    def qpsk_amp(self,value):
        value=(value&1) << 6

        self.control_val=self.control_val & (2**32 -1-2**6)  #first reset the bit in question
        self.control_val=self.control_val | value	  #then set them	
        self.set_control(self.control_val)



#This sets TX mode, need to set_FIR_in_val to 1 to use data from TX fifo and enables ssb modulator
#Ensures bits 1 and 4 are set to transmit from ARM data (eg from BT mic)
#checks bit 5 is zero
#Doesn't change the side band selected
    def set_TX_Mode_ARM(self):

        self.control_val=self.control_val & (2**32 -1 -2**5)
        self.control_val=self.control_val | 2+2**4
        self.set_control(self.control_val)

#This sets TX mode, need to set_FIR_in_val to 0 and CIC input to transmit from ADC 1 direct input (microphone) and enables ssb modulator
#Ensures bits 1 and 5 are set and bit 4 is reset
#Doesn't change the side band selected
    def set_TX_Mode_Mic(self):

        self.control_val=self.control_val & (2**32 -1 -2**4)
        self.control_val=self.control_val | 2 + 2**5
        self.set_control(self.control_val)

#This sets RX mode, sets_FIR_in_val to 0 to use data from ADC and disables ssb modulator (resets bits 1 and 4 to zero)
#resets bits 1,2,3,4 and 5 to zero (disable SSB modulator and input to FIR from CIC and CIC from the antenna input to the ADC0 also set data stream to ARM fo be from the SSB demod)
#The side band mode is not changed (bit 0)
    def set_RX_Mode(self):

        self.control_val=self.control_val & (2**32 -1 -2 -2**2 -2**3 -2**4 -2**5)
        self.set_control(self.control_val)

#Choose what to stream from FPGA to ARM:
#0 RX SSB demod
#1 Cordic (amp, lowest 16 bits and phase, highest 16 bits)
#2 Phase slope (zero padded to 32 bits)
#3 Concatenated I and Q data after FIRs
    def set_data_RX_value(self,value):
        value=(value&3) << 2

        self.control_val=self.control_val & (2**32 -1-2**2 -2**3)  #first reset the bits in question
        self.control_val=self.control_val | value	  #then set them	
        self.set_control(self.control_val)




    def get_control_val(self):
        return self.control_val



# Set DDS frequency within FPGA (used for LO )
    @command(classname="Dds")
    def set_dds_freq(self, freq):
        pass

#This needs to be adjusted carefully so will not be exactly 77500 for Frankfurt!
    @command(classname="Dds")
    def set_msf_dds_freq(self, freq):
        pass
