# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
#source $project_path/fpga/lib/starting_point_withUart.tcl - couldn't enable uart1 !?
source $sdk_path/fpga/lib/starting_point.tcl

# Add config and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts
source $project_path/board_connectionsN4Z_v2.tcl
source $board_path/analogue.tcl
#source $board_path/pmods.tcl

#create_bd_port -dir I -from 7 -to 0 pmod_ja
create_bd_port -dir O -from 7 -to 0 pmod_jb

#create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 data_clk_in <This doesn't do anything!

create_bd_port -dir O CS5340_MCLK
create_bd_port -dir O Button_Active
create_bd_port -dir O CS5340_NRST
create_bd_port -dir O SSB_Out0
create_bd_port -dir O SSB_Out1
create_bd_port -dir I TP_IRQ
create_bd_port -dir O RST
create_bd_port -dir O LCD_RS
create_bd_port -dir O LCD_CS
create_bd_port -dir O TP_CS
create_bd_port -dir O TestOut
create_bd_port -dir O TX_High
create_bd_port -dir O audio_speaker
create_bd_port -dir O Volume

# create_bd_port -dir O LCD_E
# create_bd_port -dir O LCD_RW
# create_bd_port -dir O LCD_RS
# create_bd_port -dir O LCD_V0
# create_bd_port -dir O -from 7 -to 2 LCD


create_bd_port -dir I Uart_RX
create_bd_port -dir O Uart_TX


create_bd_port -dir I CS5340_SDout
create_bd_port -dir I CS5340_SCLK
create_bd_port -dir I CS5340_LRCLK

  set user_dio [ create_bd_port -dir O -from 6 -to 0 user_dio ]
  set led0 [ create_bd_port -dir O -from 2 -to 0 led0 ]
  set led1 [ create_bd_port -dir O -from 2 -to 0 led1 ]

create_bd_port -dir O user_spi_mosi 
create_bd_port -dir O -from  1 -to 0 user_spi_ss
create_bd_port -dir O user_spi_sck 
create_bd_port -dir I user_spi_miso 

#Connect UART pins
#PS uart1 did not enable
#connect_port_pin Uart_RX ps_0/UART1_RX
#connect_port_pin Uart_TX ps_0/UART1_TX
#see AXI uartlite instance below

# Connect LEDs to config register
connect_port_pin led0 [get_slice_pin ctl/led 2 0]
connect_port_pin led1 [get_slice_pin ctl/led 5 3]



#Note the user_dio pins are offset 1 as they seem to need to start from 0!
connect_port_pin user_dio [get_slice_pin [ctl_pin user_io] 6 0]


connect_pin [sts_pin ck_inner_io] ctl/ssb_tx_frequency


# Rename clocks - adc_clk in this is 12.8MHz - ie 64x Sample rate of 200ksps and about 1/8 of the ps clock
set adc_clk CS5340_SCLK

#/peripheral_reset


# Add processor system reset synchronous to adc clock
set rst_adc_clk_name proc_sys_reset_adc_clk
cell xilinx.com:ip:proc_sys_reset:5.0 $rst_adc_clk_name {} {
  ext_reset_in $ps_name/FCLK_RESET0_N
  slowest_sync_clk $adc_clk
}



#Create clock for DAC, data output

cell xilinx.com:ip:clk_wiz clk_wiz_0 {
CLKOUT2_USED false
CLKOUT1_REQUESTED_OUT_FREQ 25.6
CLKOUT2_REQUESTED_OUT_FREQ 200
MMCM_DIVCLK_DIVIDE 5
MMCM_CLKFBOUT_MULT_F 48.000
MMCM_CLKOUT0_DIVIDE_F 37.5
MMCM_CLKOUT1_DIVIDE 1
NUM_OUT_CLKS 1
CLKOUT1_JITTER 316

CLKOUT1_PHASE_ERROR 301.6


} {
    clk_in1 ps_0/fclk_clk0
    reset proc_sys_reset_0/peripheral_reset
}




#Feb 2023 change input clock to adc_clk to reduce jitter tx to rx and hit 65.536 exactly!
cell xilinx.com:ip:clk_wiz clk_wiz_1 {

PRIM_IN_FREQ 12.8
CLKIN1_JITTER_PS 781.25
CLKOUT1_REQUESTED_OUT_FREQ 65.536 
MMCM_DIVCLK_DIVIDE 1 
MMCM_CLKFBOUT_MULT_F 64.000 
MMCM_CLKOUT0_DIVIDE_F 12.500
MMCM_CLKIN1_PERIOD 78.125 
CLKOUT1_JITTER 450.069 
CLKOUT1_PHASE_ERROR 628.490



} {
    clk_in1 $adc_clk
    reset $rst_adc_clk_name/peripheral_reset
}

#clk_wiz_1/clk_out1 is at 65.536MHz ie 8192 (2^13) times 8kHz



cell TE:user:i2s_rx:1.0 adc_reader {

} {
Clock   CS5340_SCLK
Reset  proc_sys_reset_adc_clk/peripheral_reset
LRClock  CS5340_LRCLK
Data  CS5340_SDout
}




# Add XADC for battery and antenna current monitoring - actually adc module should already be added!
#source $sdk_path/fpga/lib/xadc.tcl
#add_xadc xadc


# Use AXI Stream clock converter (ADC clock -> FPGA clock)
set intercon_idx 0






#Did use    DDS_Clock_Rate [expr [get_parameter adc_clk] / 1000000]
cell xilinx.com:ip:dds_compiler:6.0 dds {
   PartsPresent Phase_Generator_and_SIN_COS_LUT
   DDS_Clock_Rate 0.2
   Parameter_Entry Hardware_Parameters
   Phase_Width 48
   Output_Width 16
   Phase_Increment Programmable
   Latency_Configuration Configurable
   Latency 9
 } {
   aclk $adc_clk
 }
  cell pavel-demin:user:axis_constant:1.0 phase_increment {
   AXIS_TDATA_WIDTH 48
 } {
   cfg_data [get_concat_pin [list [ctl_pin phase_incr0] [get_slice_pin [ctl_pin phase_incr1] 15 0]]]
   aclk $adc_clk
   M_AXIS dds/S_AXIS_CONFIG
 }


#Add LO to detect MSF at 60kHz or 77.5kHz
cell xilinx.com:ip:dds_compiler:6.0 dds_msf {
   PartsPresent Phase_Generator_and_SIN_COS_LUT
   DDS_Clock_Rate 0.2
   Parameter_Entry Hardware_Parameters
   Phase_Width 48
   Output_Width 16
   Phase_Increment Programmable
   Latency_Configuration Configurable
   Latency 9
 } {
   aclk $adc_clk
 }
  cell pavel-demin:user:axis_constant:1.0 phase_increment_msf {
   AXIS_TDATA_WIDTH 48
 } {
   cfg_data [get_concat_pin [list [ctl_pin msf_phase_incr0] [get_slice_pin [ctl_pin msf_phase_incr1] 15 0]]]
   aclk $adc_clk
   M_AXIS dds_msf/S_AXIS_CONFIG
 }



#####################################
# Complex multiply
#####################################

    cell pavel-demin:user:axis_lfsr:1.0 lfsr {} {
        aclk $adc_clk
        aresetn $rst_adc_clk_name/peripheral_aresetn
    }


#Jan 2022 overhall bit widths to get levels right and use an AGC between CIC and FIR and between FIR and Cordic

#2022 Output width 24>17 (only use lowest 16)
# Maybe need to strobe tvalid with [get_and_pin adc_reader/IsUpdate adc_reader/IsLeft LeftValid ] and use LeftValid/res or something for the clock convertor - but then what is the clock convertor for? Maybe it should be used after FIR??
#Should be:         s_axis_a_tdata [get_concat_pin [list [get_slice_pin adc_reader/Audio 31 16] [get_constant_pin 0 16]] concat_ADC0]

  cell xilinx.com:ip:cmpy:6.0 complex_mult {
      APortWidth 16
      BPortWidth 16
      OutputWidth 24
      OptimizeGoal Performance
      RoundMode Random_Rounding
  } {
	aclk $adc_clk
        s_axis_a_tdata [get_concat_pin [list [get_slice_pin adc_reader/Audio 31 16] [get_constant_pin 0 16]] concat_ADC0]
        s_axis_a_tvalid  [get_and_pin adc_reader/IsUpdate [get_not_pin adc_reader/IsLeft ] RightValid ] 

        s_axis_b_tdata dds/m_axis_data_tdata
        s_axis_b_tvalid RightValid/Res
        s_axis_ctrl_tdata lfsr/m_axis_tdata
        s_axis_ctrl_tvalid lfsr/m_axis_tvalid

}

#Add mixer to detect msf (same as radio receiver but using the msf lo)
  cell xilinx.com:ip:cmpy:6.0 complex_msf_mult {
      APortWidth 16
      BPortWidth 16
      OutputWidth 24
      OptimizeGoal Performance
      RoundMode Random_Rounding
  } {
	aclk $adc_clk
        s_axis_a_tdata concat_ADC0/dout
        s_axis_a_tvalid  RightValid/Res

        s_axis_b_tdata dds_msf/m_axis_data_tdata
        s_axis_b_tvalid RightValid/Res
        s_axis_ctrl_tdata lfsr/m_axis_tdata
        s_axis_ctrl_tvalid lfsr/m_axis_tvalid

}



#Add an AGC to adjust the i and q output levels from the multiplier to go to the cici and cicq (24>16)

cell xilinx.com:ip:mult_gen:12.0 agc_mult_i {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  [get_Q_pin [get_slice_pin complex_mult/m_axis_dout_tdata 23 0] 1 complex_mult/m_axis_dout_tvalid $adc_clk latched_mult_i_output]
        B  [get_slice_pin ctl/mult_agc_value 15 0]


}

cell xilinx.com:ip:mult_gen:12.0 agc_mult_q {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  [get_Q_pin [get_slice_pin complex_mult/m_axis_dout_tdata 47 24] 1 complex_mult/m_axis_dout_tvalid $adc_clk latched_mult_q_output]
        B  [get_slice_pin ctl/mult_agc_value 15 0]


}



#Add an AGC to adjust the i and q output levels from the msf multiplier to go to the msf_cic_i and msf_cic_q (24>16)

cell xilinx.com:ip:mult_gen:12.0 msf_agc_mult_i {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  [get_Q_pin [get_slice_pin complex_msf_mult/m_axis_dout_tdata 23 0] 1 complex_msf_mult/m_axis_dout_tvalid $adc_clk latched_msf_mult_i_output]
        B  [get_slice_pin ctl/msf_agc_value 15 0]


}

cell xilinx.com:ip:mult_gen:12.0 msf_agc_mult_q {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  [get_Q_pin [get_slice_pin complex_msf_mult/m_axis_dout_tdata 47 24] 1 complex_msf_mult/m_axis_dout_tvalid $adc_clk latched_msf_mult_q_output]
        B  [get_slice_pin ctl/msf_agc_value 15 0]


}


cell xilinx.com:ip:cordic:6.0 cordic_msf_mult_level_mon {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 16
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid [get_Q_pin complex_msf_mult/m_axis_dout_tvalid 3 noce $adc_clk msf_delayed_tvalid]
    s_axis_cartesian_tdata [get_concat_pin [list msf_agc_mult_i/P msf_agc_mult_q/P] msf_mult_iq_vals]

}

#averager:1.0 is for unsigned amplitudes (eg from a cordic), whereas averager:1.1 is for signed values such as i and q signals
cell GN:user:mag_averager:1.0 msf_level_monitor_mult {
ABITS 12
NBITS 16

} {
clk $adc_clk
next cordic_msf_mult_level_mon/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_msf_mult_level_mon/m_axis_dout_tdata 15 0] 1 cordic_msf_mult_level_mon/m_axis_dout_tvalid $adc_clk msf_mult_amplitude_latched ]
}


connect_pin [sts_pin msf_average_mult] [get_concat_pin [list msf_level_monitor_mult/average [get_constant_pin 0 16 ] ] msf_average_mult]



# Define CIC parameters for msf filter (high decimation)

set diff_delay_msf [get_parameter cic_msf_differential_delay]
set dec_rate_msf [get_parameter cic_msf_decimation_rate]
set n_stages_msf [get_parameter cic_msf_n_stages]

cell xilinx.com:ip:cic_compiler:4.0 cic_msf_i {
  Filter_Type Decimation
  Number_Of_Stages $n_stages_msf
  Fixed_Or_Initial_Rate $dec_rate_msf
  Differential_Delay $diff_delay_msf
  Input_Sample_Frequency [expr [get_parameter adc_clk] / 64000000.]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Input_Data_Width 16
  Quantization Truncation
  Output_Data_Width 24
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid [get_Q_pin complex_msf_mult/m_axis_dout_tvalid 4 noce $adc_clk msf_delayed_tvalid]
  s_axis_data_tdata msf_agc_mult_i/P


}

cell xilinx.com:ip:cic_compiler:4.0 cic_msf_q {
  Filter_Type Decimation
  Number_Of_Stages $n_stages_msf
  Fixed_Or_Initial_Rate $dec_rate_msf
  Differential_Delay $diff_delay_msf
  Input_Sample_Frequency [expr [get_parameter adc_clk] / 64000000.]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Input_Data_Width 16
  Quantization Truncation
  Output_Data_Width 24
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid msf_delayed_tvalid/Q
  s_axis_data_tdata msf_agc_mult_q/P


}

#now agc for msf cic_msf
cell xilinx.com:ip:mult_gen:12.0 agc_cic_msf_i {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  cic_msf_i/m_axis_data_tdata
        B  [get_slice_pin ctl/msf_agc_value 31 16]


}

cell xilinx.com:ip:mult_gen:12.0 agc_cic_msf_q {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15
PipeStages 3
        } {

        CLK $adc_clk
        A  cic_msf_q/m_axis_data_tdata
        B  [get_slice_pin ctl/msf_agc_value 31 16]


}




cell xilinx.com:ip:cordic:6.0 cordic_cic_msf_level_mon {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 16
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid cic_msf_i/m_axis_data_tvalid
    s_axis_cartesian_tdata [get_concat_pin [list agc_cic_msf_i/P agc_cic_msf_q/P] cic_msf_iq_vals]

}

#Monitor level of cic on the msf signal and phase
cell GN:user:averager:1.1 level_monitor_cic_msf_i {
ABITS 7
AMBITS 4
SKIPBITS 1
} {
clk $adc_clk
next [get_and_pin [get_not_pin [get_slice_pin ctl/control 1 1]] cordic_cic_msf_level_mon/m_axis_dout_tvalid gated_msf_strobeI ]
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin agc_cic_msf_i/P 1 cic_msf_i/m_axis_data_tvalid $adc_clk cic_msf_i_latched ]
}

cell GN:user:averager:1.1 level_monitor_cic_msf_q {
ABITS 7
AMBITS 4
SKIPBITS 1
} {
clk $adc_clk
next [get_and_pin [get_not_pin [get_slice_pin ctl/control 1 1]] cordic_cic_msf_level_mon/m_axis_dout_tvalid gated_msf_strobeQ ]
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin agc_cic_msf_q/P 1 cic_msf_q/m_axis_data_tvalid $adc_clk cic_msf_q_latched ]
}

cell GN:user:mag_averager:1.0 level_monitor_cic_msf {
ABITS 5
NBITS 16

} {
clk $adc_clk
next cordic_cic_msf_level_mon/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_cic_msf_level_mon/m_axis_dout_tdata 15 0] 1 cordic_cic_msf_level_mon/m_axis_dout_tvalid $adc_clk cic_msf_amplitude_latched ]
}




connect_pin [sts_pin msf_average_amplitude]  [get_concat_pin [list level_monitor_cic_msf/average [get_constant_pin 0 16 ] ] msf_average_cic]




connect_pin [sts_pin msf_i] [get_concat_pin [list level_monitor_cic_msf_i/average [get_constant_pin 0 16 ] ] msf_average_i]
connect_pin [sts_pin msf_q] [get_concat_pin [list level_monitor_cic_msf_q/average [get_constant_pin 0 16 ] ] msf_average_q]


#end msf with agc

#Timing control
cell GN:user:timing_control_msf:1.0 msf_BRAM_timing {
} {
msf_carrier_pulse [get_and_pin [get_slice_pin dds_msf/m_axis_data_tdata 31 31] [get_not_pin  [get_Q_pin [get_slice_pin dds_msf/m_axis_data_tdata 31 31]  1 noce $adc_clk delayed_dds] ]  msf_carrier_pulse]

msf_frequency [get_slice_pin ctl/msf_frequency 8 0]
low_time [get_slice_pin ctl/msf_low_time 7 0]
rst [get_slice_pin ctl/control 15 15]
clk $adc_clk
}


set Not_TXHigh [get_not_pin [get_slice_pin ctl/control 1 1]]

#Now add library to introduce block rams read for PS interface - or should we be using bram_recorder instead?:
source $project_path/tcl/bram_sender.tcl
# - and need to add interface at end (see LDS
add_bram_sender  Sec_bram SecondBRAM
connect_cell Sec_bram {
  clk $adc_clk
  rst $rst_adc_clk_name/peripheral_reset
  addr [get_concat_pin [list  [get_constant_pin 0 2] msf_BRAM_timing/address_counter ] padded_ram_addr ]
  wen [get_and_pin [get_concat_pin [list $Not_TXHigh $Not_TXHigh $Not_TXHigh $Not_TXHigh ] NotHighExt] msf_BRAM_timing/write_second_bram gated_msf_write]
  data_in [get_concat_pin [list cic_msf_i_latched/Q cic_msf_q_latched/Q  ] concat_msf_iq]
}


cell xilinx.com:ip:cordic:6.0 cordic_mult_level_mon {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 16
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid [get_Q_pin complex_mult/m_axis_dout_tvalid 3 noce $adc_clk delayed_tvalid]
    s_axis_cartesian_tdata [get_concat_pin [list agc_mult_i/P agc_mult_q/P] mult_iq_vals]

}


#Now try longer time constant monitor
#Speed it up again by knocking 4 bits off ABITS and SKIPBITS June 2022
cell GN:user:mag_averager:1.0 level_monitor_mult {
ABITS 12
NBITS 16

} {
clk $adc_clk
next cordic_mult_level_mon/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_mult_level_mon/m_axis_dout_tdata 15 0] 1 cordic_mult_level_mon/m_axis_dout_tvalid $adc_clk mult_amplitude_latched ]
}


connect_pin [sts_pin average_mult] [get_concat_pin [list level_monitor_mult/average [get_constant_pin 0 16 ] ] average_mult]

#add AXI uartlite
#(first add an axi interconnect allocation):
set idx [add_master_interface $intercon_idx]

cell xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 {
C_BAUDRATE 115200
} {
  s_axi_aclk [set ps_clk$intercon_idx]
  s_axi_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  S_AXI [set interconnect_${intercon_idx}_name]/M${idx}_AXI

}

#Now connect up
connect_port_pin Uart_RX axi_uartlite_0/rx
connect_port_pin Uart_TX axi_uartlite_0/tx

#2022 Widths 24>16 on mux inputs
#Choose input to cic - either RX from antenna downconvert or audio from mic on ADC channel 2

cell GN:user:moving_average_9:1.0 mic_notch_filter {
DATA_WIDTH 16
} {
            clk  $adc_clk 
           ce [get_and_pin adc_reader/IsUpdate adc_reader/IsLeft LeftValid ]
            din [get_Q_pin [get_slice_pin adc_reader/Audio 31 16] 1 LeftValid/Res  $adc_clk latched_mic_input ]

}



cell koheron:user:latched_mux:1.0 data_for_cic_i {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 5 5]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list agc_mult_i/P  mic_notch_filter/dout ] cic_i_inputs ]

        }

cell koheron:user:latched_mux:1.0 data_for_cic_q {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 5 5]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list agc_mult_q/P  mic_notch_filter/dout] cic_q_inputs ]

        }

#2022 widths 24/32 > 16/24
# Define CIC parameters

set diff_delay [get_parameter cic_differential_delay]
set dec_rate [get_parameter cic_decimation_rate]
set n_stages [get_parameter cic_n_stages]

cell xilinx.com:ip:cic_compiler:4.0 cic_i {
  Filter_Type Decimation
  Number_Of_Stages $n_stages
  Fixed_Or_Initial_Rate $dec_rate
  Differential_Delay $diff_delay
  Input_Sample_Frequency [expr [get_parameter adc_clk] / 64000000.]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Input_Data_Width 16
  Quantization Truncation
  Output_Data_Width 24
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid [get_Q_pin complex_mult/m_axis_dout_tvalid 4 noce $adc_clk delayed_tvalid]
  s_axis_data_tdata data_for_cic_i/dout


}

cell xilinx.com:ip:cic_compiler:4.0 cic_q {
  Filter_Type Decimation
  Number_Of_Stages $n_stages
  Fixed_Or_Initial_Rate $dec_rate
  Differential_Delay $diff_delay
  Input_Sample_Frequency [expr [get_parameter adc_clk] / 64000000.]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Input_Data_Width 16
  Quantization Truncation
  Output_Data_Width 24
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid delayed_tvalid/Q
  s_axis_data_tdata data_for_cic_q/dout


}

set idx [add_master_interface $intercon_idx]
#BT mic input 
cell xilinx.com:ip:axi_fifo_mm_s:4.1 tx_axis_fifo {
  C_USE_RX_DATA 0
  C_USE_TX_CTRL 0
  C_USE_TX_CUT_THROUGH true

  C_TX_FIFO_DEPTH 4096
  C_TX_FIFO_PF_THRESHOLD 4000
  C_TX_FIFO_PE_THRESHOLD 6
} {
  s_axi_aclk [set ps_clk$intercon_idx]
  s_axi_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  S_AXI [set interconnect_${intercon_idx}_name]/M${idx}_AXI

}



#The tready signal is now dropped down to 8ksps to reduce flow rate from PS txfifo . Upsampling is done at the input of the fir (just retains the value for 5 clock pulses)!
cell xilinx.com:ip:axis_clock_converter:1.1 tx_clock_converter {
  TDATA_NUM_BYTES 4
} {
  s_axis_tdata tx_axis_fifo/axi_str_txd_tdata  
  s_axis_tvalid tx_axis_fifo/axi_str_txd_tvalid
  s_axis_tready tx_axis_fifo/axi_str_txd_tready

  m_axis_aresetn $rst_adc_clk_name/peripheral_aresetn
  s_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  m_axis_aclk $adc_clk
  s_axis_aclk [set ps_clk$intercon_idx]
}



#2022 put AGC here controlled by ARM with level monitor after it. But will need a cordic to get the amplitude
#Need to use a multiplier instead of a mux!
#ERROR: [IP_Flow 19-3458] Validation failed for parameter 'Const Width(CONST_WIDTH)' for BD Cell 'const_v1_w0'. Value '0' is out of the range (1,4096)

cell xilinx.com:ip:mult_gen:12.0 agc_cic_i {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15 
PipeStages 3
        } {

        CLK $adc_clk
        A  cic_i/m_axis_data_tdata
        B  [get_slice_pin ctl/agc_value 31 16]


}

cell xilinx.com:ip:mult_gen:12.0 agc_cic_q {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15
PipeStages 3
        } {

        CLK $adc_clk
        A  cic_q/m_axis_data_tdata
        B  [get_slice_pin ctl/agc_value 31 16]


}





cell xilinx.com:ip:cordic:6.0 cordic_cic_level_mon {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 16
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid cic_i/m_axis_data_tvalid
    s_axis_cartesian_tdata [get_concat_pin [list agc_cic_i/P agc_cic_q/P] cic_iq_vals]

}

#use new level monitor to slow decay
#Speed it up again by knocking 4 bits off ABITS and SKIPBITS June 2022
cell GN:user:mag_averager:1.0 level_monitor_cic {
ABITS 5
NBITS 16

} {
clk $adc_clk
next cordic_cic_level_mon/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_cic_level_mon/m_axis_dout_tdata 15 0] 1 cordic_cic_level_mon/m_axis_dout_tvalid $adc_clk cic_amplitude_latched ]
}




#mux options
#[get_concat_pin [list [get_slice_pin cic_i/m_axis_data_tdata 22 7] [get_slice_pin cic_i/m_axis_data_tdata 21 6] [get_slice_pin cic_i/m_axis_data_tdata 20 5] [get_slice_pin cic_i/m_axis_data_tdata 19 4] [get_slice_pin cic_i/m_axis_data_tdata 18 3] [get_slice_pin cic_i/m_axis_data_tdata 17 2] [get_slice_pin cic_i/m_axis_data_tdata 16 1] [get_slice_pin cic_i/m_axis_data_tdata 15 0] ] cic_i_levels]


#2022 widths 32 > 16 - note that only takes upper 16 bits from tx fifo

cell koheron:user:latched_mux:1.0 data_for_fir_i {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 4 4]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list agc_cic_i/P  [get_Q_pin [get_slice_pin tx_clock_converter/m_axis_tdata 31 16] 1 tx_clock_converter/m_axis_tvalid $adc_clk latched_txfifo_value] ] fir_i_inputs ]

        }

cell koheron:user:latched_mux:1.0 data_for_fir_q {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 4 4]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list agc_cic_q/P  [get_Q_pin [get_slice_pin tx_clock_converter/m_axis_tdata 31 16] 1 tx_clock_converter/m_axis_tvalid $adc_clk latched_txfifo_value] ] fir_q_inputs ]

        }




# Load fir set value if fir_set value changes
 cell koheron:user:comparator:1.0 update_fir_coeffs {
    DATA_WIDTH 8
    OPERATION "NE"
  } {
    a [get_Q_pin [get_concat_pin [list [get_or_pin [get_slice_pin ctl/control 5 5] [get_slice_pin ctl/control 4 4] fir_set_logic] [get_constant_pin 0 7]] fir_set] 2 "noce" $adc_clk]
    b [get_Q_pin fir_set/dout 3 "noce" $adc_clk]
  }




#2022 widths 32/32/32 > 16/16/24
#2022 April changed FIR to have 2 sets of coefficients (RX and TX)
set dec_rate_fir [get_parameter fir_decimation_rate]
#Data input rate at 40kHz paced by the cic
set fidi_rx [open $project_path/128tap_i_rx_deemph.txt r]
set fidi_tx [open $project_path/128tap_i_tx_preemph.txt r]
gets $fidi_rx charsi_rx
gets $fidi_tx charsi_tx
set fir_coeffs_i [concat $charsi_rx  " , " $charsi_tx ]
puts stdout fir_coeffs_i

set fidq_rx [open $project_path/128tap_q_rx_deemph.txt r]
set fidq_tx [open $project_path/128tap_q_tx_preemph.txt r]
gets $fidq_rx charsq_rx
gets $fidq_tx charsq_tx
set fir_coeffs_q [concat $charsq_rx  " , " $charsq_tx ]

puts stdout fir_coeffs_q

set n_fir_sets  [get_parameter n_fir_sets]
#was: [exec python $project_path/fir.py $n_stages $dec_rate $diff_delay print]

#removed:
#  Quantization Maximize_Dynamic_Range 
#  Coefficient_Fractional_Bits 33 
#  Coefficient_Structure Inferred 


#!!!!!!!! should fclk0 be replaced with adc_clk rather than fclk0? - and does it really matter much or just affect the speed optimisation of the routing?
#Done 25 Oct 22
cell xilinx.com:ip:fir_compiler:7.2 fir_i {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Coefficient_Width 16
  Data_Width 16
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 24
  Decimation_Rate $dec_rate_fir
  BestPrecision true
  Coefficient_Sets $n_fir_sets
  CoefficientVector [subst {{$fir_coeffs_i}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_i/m_axis_data_tvalid
  s_axis_data_tdata data_for_fir_i/dout

  S_AXIS_CONFIG_TDATA [get_Q_pin fir_set/dout 1 "noce"  $adc_clk latch_fir_set]
  S_AXIS_CONFIG_TVALID update_fir_coeffs/dout


}

cell xilinx.com:ip:fir_compiler:7.2 fir_q {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Coefficient_Width 16
  Data_Width 16
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 24
  Decimation_Rate $dec_rate_fir
  BestPrecision true
  Coefficient_Sets $n_fir_sets
  CoefficientVector [subst {{$fir_coeffs_q}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_q/m_axis_data_tvalid
  s_axis_data_tdata data_for_fir_q/dout
  
  S_AXIS_CONFIG_TDATA latch_fir_set/Q
  S_AXIS_CONFIG_TVALID update_fir_coeffs/dout
}


#Add AGC here (but don't need level monitor as this is done after the regular cordic used by ssb)
cell xilinx.com:ip:mult_gen:12.0 agc_fir_i {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15
PipeStages 3
        } {

        CLK $adc_clk
        A  fir_i/m_axis_data_tdata
        B  [get_slice_pin ctl/agc_value 15 0]


}

cell xilinx.com:ip:mult_gen:12.0 agc_fir_q {
PortBType Unsigned 
PortAWidth 24 
PortBWidth 16 
Multiplier_Construction Use_Mults 
Use_Custom_Output_Width true 
OutputWidthHigh 30 
OutputWidthLow 15
PipeStages 3
        } {

        CLK $adc_clk
        A  fir_q/m_axis_data_tdata
        B  [get_slice_pin ctl/agc_value 15 0]


}



connect_pin   tx_clock_converter/m_axis_tready fir_i/m_axis_data_tvalid



#2022 widths 32>16

cell xilinx.com:ip:c_addsub:12.0 c_addsub_0 {
B_Width.VALUE_SRC USER 
A_Width.VALUE_SRC USER 
A_Type.VALUE_SRC USER

Implementation Fabric 
A_Width 16 
B_Width 16 
Add_Mode Add_Subtract 
Out_Width 16 
CE false 
Latency 1 
B_Value 0000000000000000

} {
A agc_fir_i/P
B agc_fir_q/P
CLK $adc_clk
ADD [get_slice_pin ctl/control 0 0]
}



cell xilinx.com:ip:cordic:6.0 cordic_ssb {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 16
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid fir_i/m_axis_data_tvalid
    s_axis_cartesian_tdata [get_concat_pin [list agc_fir_i/P  agc_fir_q/P ] concat_audio_iq]

}

#This is actually OK - could drop to 14 bit input, but the slicing at the ssb corrects the phase differences as 14 bit signed values (ie -10000 becomes +6834)
#The data fifo misinterprets it though :-(
cell xilinx.com:ip:c_addsub:12.0 diff_phase {
B_Width.VALUE_SRC USER 
A_Width.VALUE_SRC USER 
A_Type.VALUE_SRC USER

Implementation Fabric 
A_Width 16 
B_Width 16 
Add_Mode Subtract 
Out_Width 17 
CE false 
Latency 1 
B_Value 0000000000000000

} {
A [get_Q_pin [get_slice_pin cordic_ssb/m_axis_dout_tdata 31 16] 1 cordic_ssb/m_axis_dout_tvalid $adc_clk cordic_phase_latched_8k ]
B [get_Q_pin cordic_phase_latched_8k/Q 1 cordic_ssb/m_axis_dout_tvalid $adc_clk]
CLK $adc_clk

}

#Slow FIR time constant to ~0.5s
#Speed it up again by knocking 4 bits off ABITS and SKIPBITS June 2022
cell GN:user:mag_averager:1.0 level_monitor {
ABITS 8
NBITS 16

} {
clk $adc_clk
next cordic_ssb/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] 1 cordic_ssb/m_axis_dout_tvalid $adc_clk cordic_amplitude_latched_8k ]
}


connect_pin [sts_pin average_amplitude] [get_concat_pin [list level_monitor/average level_monitor_cic/average] average_cic_fir]
connect_pin [sts_pin max_amplitude] [get_concat_pin [list level_monitor/max_val level_monitor_cic/max_val] max_cic_fir]






cell GN:user:QPSK_timing:1.1 qpsk_timing {
} {
cic_40_pulse cic_i/m_axis_data_tvalid
rst  $rst_adc_clk_name/peripheral_reset

clk $adc_clk

}


#Now QPSK reading is averaged using an FIR over 4 40ksps CIC values and not msf timing so should use regular average (IQ_averager_1_2) not IQ_averager1,1 , but BRAM writing is synced to 1s timing from MSF. FIR has a notch at 6kHz to remove 81kHz parasite when using 87kHz carrier


set fidi_msf [open $project_path/32_Tap_LPF_6kHzNotchList.txt r]

gets $fidi_msf charsi_msf_rx

set fir_coeffs_msf  $charsi_msf_rx
puts stdout fir_coeffs_msf



cell xilinx.com:ip:fir_compiler:7.2 fir_msf_i {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Coefficient_Width 16
  Data_Width 16
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 16
  Decimation_Rate 4
  BestPrecision true
  CoefficientVector [subst {{$fir_coeffs_msf}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_i/m_axis_data_tvalid
  s_axis_data_tdata agc_cic_i/P

}

cell xilinx.com:ip:fir_compiler:7.2 fir_msf_q {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Coefficient_Width 16
  Data_Width 16
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 16
  Decimation_Rate 4
  BestPrecision true
  CoefficientVector [subst {{$fir_coeffs_msf}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_q/m_axis_data_tvalid
  s_axis_data_tdata agc_cic_q/P

}




#Need to write IQBRAM only on RX!
set TX_not_high_write [get_and_pin fir_msf_i/m_axis_data_tvalid  [get_not_pin [get_slice_pin ctl/control 1 1]] ]


add_bram_sender  IQ_bram IQBRAM
connect_cell IQ_bram {
  clk $adc_clk
  rst $rst_adc_clk_name/peripheral_reset
  addr [get_concat_pin [list  [get_constant_pin 0 2] [get_slice_pin qpsk_timing/cic_pulse_counter 15 2] ] padded_iqram_addr ]
  wen [get_concat_pin [list $TX_not_high_write $TX_not_high_write $TX_not_high_write $TX_not_high_write ] IQramWrite ]
  data_in [get_concat_pin [list  fir_msf_i/m_axis_data_tdata   fir_msf_q/m_axis_data_tdata ] IQconcat_ave]
}

#above was data_in [get_concat_pin [list [get_slice_pin msf_bram_timing/second_250_counter 3 0] [get_slice_pin fir_msf_i/m_axis_data_tdata 15 4] [get_slice_pin msf_bram_timing/second_250_counter 7 4] [get_slice_pin fir_msf_q/m_axis_data_tdata 15 4] ] IQconcat_ave]



#Note this reads the carrier counter 0-3999 (advancing at 250Hz) which modulo 250 gives the timing within the second cycle if you subtract 'low_time'. The upper 16 bits have the IQBRAM address (which increments in 4 at 10kHz) corresponding to that time in the cycle.
connect_pin [sts_pin msf_carrier_counter] [get_concat_pin [list msf_BRAM_timing/address_counter [get_constant_pin 0 4]  padded_iqram_addr/dout]]

#End IQBRAM insert



#Dec 21 insert mux to switch to fixed (2**25-2**20) QPSK amplitude when control bit 6 set to 1
#SSB bit was "[get_concat_pin  [list [get_constant_pin 0 12] [get_slice_pin cordic_ssb/m_axis_dout_tdata 14 0] ] padded_amplitude]" but tried scaling a factor of 2 (dec 2021)

#cell koheron:user:latched_mux:1.0 amplitude_select {
#            WIDTH 28
#    	    N_INPUTS 2
#            SEL_WIDTH 1
#        } {
#            clk  clk_wiz_1/clk_out1
#            sel [get_slice_pin ctl/control 6 6]
#            clken [get_constant_pin 1 1]
#            din [get_Q_pin [get_concat_pin [list [get_concat_pin  [list [get_constant_pin 0 12] [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] ] padded_amplitude] #[get_constant_pin 32500000 28]] amplitude_options ] 1 noce clk_wiz_1/clk_out1 latched_amp_options]
#



#clk_wiz_1/clk_out1 is at 8x8.192MHz ie 8192 (2^13) times 8kHz
#Amplitude adjusted 31/1/21 to get the maximum dynamic range from the SSB modulation
#Originally controlled phase with qpsk_phase [get_slice_pin ctl/qpsk 26 0]


cell GN:user:ssbiq_modulator:1.0 ssb_tx {
NBITS 24
} {
 clk clk_wiz_1/clk_out1
 rst $rst_adc_clk_name/peripheral_reset
 delta_phase [get_slice_pin diff_phase/S 13 0] 
 ssb_freq  [get_slice_pin ctl/ssb_tx_frequency 29 0] 
 amplitude [get_Q_pin [get_concat_pin  [list [get_constant_pin 0 12] [get_slice_pin cordic_ssb/m_axis_dout_tdata 14 0] ] padded_amplitude] 1 noce clk_wiz_1/clk_out1 latched_amplitude]
 stdby [get_not_pin [get_slice_pin ctl/control 1 1] ]
 set_qpsk [get_slice_pin ctl/control 6 6]
 qpsk_phase [get_slice_pin IQ_bram/data_out 26 0]
}

#cell GN:user:photodiode_delay:1.0 pd_delays {
#} {
# clk ps_0/fclk_clk0
# rst [get_slice_pin ctl/control 30 30]
# 
#}


#Now just read simple button status on pd inputs PD pins no longer used
#connect_port_pin PD sts/pd


#connect_bd_net [get_bd_pins concat_PD1_PD2_PD3_PD4_PD5/dout] [get_bd_pins pd_delays/PD]

#connect_pin [get_concat_pin [list pd_delays/PD0_delay [get_constant_pin 0 20]]] sts/pd0_delay
#connect_pin pd_delays/PD_delays  sts/pd
#connect_port_pin Button_Active pd_delays/button_activate

#Temporarily connect PD signals to LCD signals
#connect_port_pin LCD  [get_concat_pin [list  PD pd_delays/button_activate [get_constant_pin 0 2] ] ] 

connect_pin sts/display_i [get_concat_pin [list TP_IRQ [get_constant_pin 0 31]]]




connect_port_pin RST [get_slice_pin ctl/display_o 0 0]
connect_port_pin  LCD_RS [get_slice_pin ctl/display_o 1 1]
connect_port_pin  LCD_CS [get_slice_pin ctl/display_o 2 2]
connect_port_pin  TP_CS [get_slice_pin ctl/display_o 3 3]

#connect_port_pin  LCD [get_slice_pin ctl/lcd 7 0]
# connect_port_pin  LCD_E [get_slice_pin ctl/lcd 8 8]
# connect_port_pin  LCD_RW [get_slice_pin ctl/lcd 9 9]
# connect_port_pin  LCD_RS [get_slice_pin ctl/lcd 10 10]
# connect_port_pin  LCD_V0 [get_slice_pin ctl/lcd 11 11]
connect_port_pin SSB_Out0 ssb_tx/DRV0 
connect_port_pin SSB_Out1 ssb_tx/DRV1 

#These mux inputs should be on $adc_clk
#Bit width of addsub is now 16bits
set idx [add_master_interface $intercon_idx]


#Normal concat input:
#  [get_concat_pin [list c_addsub_0/S [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] ] SSBrx_CORDICamp] \
#  [get_concat_pin [list [get_slice_pin diff_phase/S 15 0] [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] ]  ] \
#  concat_audio_iq/dout \
#  [get_concat_pin [list agc_cic_i/P  agc_cic_q/P ] concat_cic_iq] \
#  adc_reader/Audio \
#  dds/m_axis_data_tdata \
#  [get_concat_pin [list [get_slice_pin latched_mult_i_output/Q 23 8]  [get_slice_pin latched_mult_q_output/Q 23 8] ] concat_mult_iq] \
#  concat_cic_iq/dout \
#wanting to use    msf_mult_iq_vals/dout \  padded_msf_signal/dout \

#Test inputs:
#  adc_reader/Audio \
#  dds/m_axis_data_tdata \
#  [get_concat_pin [list [get_slice_pin latched_mult_i_output/Q 23 8]  [get_slice_pin latched_mult_q_output/Q 23 8] ] concat_mult_iq] \
#  [get_concat_pin [list data_for_cic_i/dout  data_for_cic_q/dout ] concat_cic_iq] \



cell koheron:user:latched_mux:1.0 data_for_fifo {
            WIDTH 32
    	    N_INPUTS 8
            SEL_WIDTH 3
        } {
            clk  $adc_clk 
            sel [get_concat_pin [list [get_slice_pin ctl/control 3 2] [get_slice_pin ctl/control 7 7] ] special_sel ] 
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list \
  [get_concat_pin [list c_addsub_0/S [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] ] SSBrx_CORDICamp] \
  [get_concat_pin [list [get_slice_pin diff_phase/S 15 0] [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] ] concat_diff_phase_ssb ] \
  concat_audio_iq/dout \
  [get_concat_pin [list agc_cic_i/P  agc_cic_q/P ] concat_cic_iq] \
  adc_reader/Audio \
  [get_concat_pin [list [get_constant_pin 0 16] latched_mic_input/Q ] zero_LSB_padded_micinput] \
  concat_msf_IQ/dout \
  IQconcat_ave/dout \
 ] data_options ]

        }

#Normal tvalid options:
#fir_i/m_axis_data_tvalid \
#  fir_i/m_axis_data_tvalid \
#  fir_i/m_axis_data_tvalid \
#  cic_i/m_axis_data_tvalid \
#  RightValid/Res \
#  RightValid/Res \
#  complex_mult/m_axis_dout_tvalid \
#  delayed_tvalid/Q \

#Test tvalid options:
#  RightValid/Res \
#  RightValid/Res \
#  complex_mult/m_axis_dout_tvalid \
#  delayed_tvalid/Q \

cell koheron:user:latched_mux:1.0 tvalid_for_fifo {
            WIDTH 1
    	    N_INPUTS 8
            SEL_WIDTH 3
        } {
            clk  $adc_clk 
            sel special_sel/dout
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list \
 fir_i/m_axis_data_tvalid \
  fir_i/m_axis_data_tvalid \
  fir_i/m_axis_data_tvalid \
  cic_i/m_axis_data_tvalid \
  RightValid/Res \
  RightValid/Res \
  cic_msf_i/m_axis_data_tvalid  \
  cordic_cic_msf_level_mon/m_axis_dout_tvalid \
 ] tvalid_options ]

        }




#Need to add above  [NBITS-11:0] delta_phase and  [NBITS-1:0] amplitude plus tx_low on  stdby,
#Need to add tx fifo to receive BT mic input.

cell xilinx.com:ip:axis_clock_converter:1.1 adc_clock_converter {
  TDATA_NUM_BYTES 4
} {
  s_axis_tdata data_for_fifo/dout
  s_axis_tvalid tvalid_for_fifo/dout
  s_axis_aresetn $rst_adc_clk_name/peripheral_aresetn
  m_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  s_axis_aclk $adc_clk
  m_axis_aclk [set ps_clk$intercon_idx]
}



cell koheron:user:latched_mux:1.0 speaker_mux {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk ps_0/fclk_clk0 
            sel [get_slice_pin ctl/control 14 14]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list  [get_slice_pin adc_clock_converter/m_axis_tdata 15 0] [get_slice_pin tx_axis_fifo/axi_str_txd_tdata 15 0]] speaker_select]

        }

cell koheron:user:latched_mux:1.0 speaker_valid {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk ps_0/fclk_clk0 
            sel [get_slice_pin ctl/control 14 14]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list  adc_clock_converter/m_axis_tvalid  tx_axis_fifo/axi_str_txd_tvalid ] speaker_strobe]

        }



cell xilinx.com:ip:axis_clock_converter:1.1 speaker_clock_converter {
  TDATA_NUM_BYTES 4
} {
  s_axis_tdata speaker_mux/dout 
  s_axis_tvalid speaker_valid/dout 

  m_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  s_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  m_axis_aclk clk_wiz_0/clk_out1
  s_axis_aclk [set ps_clk$intercon_idx]
}







#Add audio output to one bit dac
#After rationalising bits (reducing signal to 16 bits) take RX audio from lower 16 bits!
cell GN:user:OB_DAC:1.0 Audio_Speaker {

} {
  i_clk clk_wiz_0/clk_out1
  i_res [set rst${intercon_idx}_name]/peripheral_aresetn
  i_ce  [get_constant_pin 1 1]
  i_func [get_Q_pin speaker_clock_converter/m_axis_tdata 1 noce clk_wiz_0/clk_out1 latched_speaker]
  o_DAC audio_speaker
}


#Volume output
cell koheron:user:pdm:1.0 volume_pwm {
        NBITS [get_parameter pwm_width]
    } {
        clk [set ps_clk$intercon_idx]
        rst [set rst${intercon_idx}_name]/peripheral_reset
    }


#Connect output to volume pin and input from volume_control register
connect_pin Volume volume_pwm/dout
connect_pin volume_pwm/din [get_slice_pin ctl/volume 12 0]




# Add AXI stream FIFO
cell xilinx.com:ip:axi_fifo_mm_s:4.1 data_axis_fifo {
  C_USE_TX_DATA 0
  C_USE_TX_CTRL 0
  C_USE_RX_CUT_THROUGH true
  C_RX_FIFO_DEPTH 4096
  C_RX_FIFO_PF_THRESHOLD 4000
} {
  s_axi_aclk [set ps_clk$intercon_idx]
  s_axi_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  S_AXI [set interconnect_${intercon_idx}_name]/M${idx}_AXI
  axi_str_rxd_tvalid adc_clock_converter/m_axis_tvalid
  axi_str_rxd_tdata   adc_clock_converter/m_axis_tdata
}



#cell xilinx.com:ip:c_counter_binary:12.0 one_bit_count {
#Output_Width 1
#CE true
#} {
#  clk $adc_clk
#  ce qpsk_timing/write
#}

connect_pin [sts_pin status] [get_concat_pin [list msf_BRAM_timing/address_counter [get_constant_pin 0 20]] padded_status]
connect_port_pin TestOut msf_BRAM_timing/one_sec_marker
# was one_bit_count/Q  or msf_BRAM_timing/one_sec_marker now counts tx axis valid pulses to give square pulse with period twice the output data period (should be 12.5Hz)
connect_port_pin TX_High [get_slice_pin ctl/control 1 1]



#These following bits to DAC module are only for interest during development and should be removed for final version
#Convert the signed number to an offset unsigned number for the DAC (only use lowest 16 bits)
#Only the lower 16 bits are sent from the data fifo mux!
cell xilinx.com:ip:c_addsub:12.0 twos_Comp_Unsigned {
B_Width.VALUE_SRC USER 
A_Width.VALUE_SRC USER 
A_Type.VALUE_SRC USER

Implementation Fabric 
A_Width 16 
B_Width 16 
Add_Mode Add
Out_Width 17 
CE false 

Latency 1 
B_Value 00000000000000000000000000000000

} {
A [get_slice_pin adc_clock_converter/m_axis_tdata 15 0]
B [get_constant_pin [expr {2**15}] 16]
CLK ps_0/fclk_clk0 

}


cell koheron:user:latched_mux:1.0 dac0_mux {
            WIDTH 16
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk ps_0/fclk_clk0 
            sel [get_slice_pin ctl/control 16 16]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list  [get_slice_pin twos_Comp_Unsigned/S 15 0] [get_slice_pin ctl/user_io 15 0]] padded_unsignDAC]

        }

#Was [get_concat_pin [list decode_20b16b/decoded_data [get_slice_pin ctl/user_io 15 0]]]
cell GN:user:ad5541:1.0 dac_out  {
} {
    clk clk_wiz_0/clk_out1
    rstn proc_sys_reset_0/peripheral_aresetn
    valid [get_constant_pin 1 1]
 }

connect_port_pin pmod_jb [get_concat_pin [list dac_out/cs dac_out/din dac_out/ldac dac_out/sclk tx_clock_converter/m_axis_tvalid cic_i/m_axis_data_tvalid tx_clock_converter/s_axis_tready tx_axis_fifo/axi_str_txd_tvalid ] concat_pmodjb]

#Connect output of mux to input of DAC module
connect_pin dac_out/data  dac0_mux/dout

#Remove DAC to here





connect_port_pin CS5340_NRST proc_sys_reset_0/peripheral_aresetn

connect_port_pin CS5340_MCLK clk_wiz_0/clk_out1
#connect_port_pin repeat_MK clk_wiz_0/clk_out1


assign_bd_address [get_bd_addr_segs data_axis_fifo/S_AXI/Mem0]
set memory_segment_data  [get_bd_addr_segs /${::ps_name}/Data/SEG_data_axis_fifo_Mem0]
set_property offset [get_memory_offset data_fifo] $memory_segment_data
set_property range  [get_memory_range data_fifo]  $memory_segment_data


assign_bd_address [get_bd_addr_segs tx_axis_fifo/S_AXI/Mem0]
set memory_segment_tx  [get_bd_addr_segs /${::ps_name}/Data/SEG_tx_axis_fifo_Mem0]
set_property offset [get_memory_offset tx_fifo] $memory_segment_tx
set_property range  [get_memory_range tx_fifo]  $memory_segment_tx


#Add these asignments to try and get Uart1 to work
assign_bd_address [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg]
set memory_segment_axi_uart  [get_bd_addr_segs /${::ps_name}/Data/SEG_axi_uartlite_0_Reg]
set_property offset [get_memory_offset axi_uart] $memory_segment_axi_uart
set_property range  [get_memory_range axi_uart]  $memory_segment_axi_uart

#assign_bd_address [get_bd_addr_segs q_ave_fifo/S_AXI/Mem0]
#set memory_segment_q_ave  [get_bd_addr_segs /${::ps_name}/Data/SEG_q_ave_fifo_Mem0]
#set_property offset [get_memory_offset ave_q_fifo] $memory_segment_q_ave
#set_property range  [get_memory_range ave_q_fifo]  $memory_segment_q_ave



#Shouldn't need tri-state buffers in this design-
#set run_autowrapper 0
#set obj [get_filesets sources_1]
#set files [list \
#"[file normalize "$board_path/config/system_top.vhd"]"\
#]
#add_files -norecurse -fileset $obj $files
#set file "$board_path/config/system_top.vhd"
#set file [file normalize $file]
#set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
#set_property "file_type" "VHDL" $file_obj
#set obj [get_filesets sources_1]
#set_property "top" "system_top" $obj

#move_bd_cells [get_bd_cells ctl]  [get_bd_cells slice_15_0_ctl_ck_outer_io] [get_bd_cells slice_12_0_ctl_user_io]
  # Create instance: axi_spi, and set properties
  cell xilinx.com:ip:axi_quad_spi:3.2 axi_spi0 {
   C_USE_STARTUP {0} 
   C_USE_STARTUP_INT {0} 
  } {
    AXI_LITE axi_mem_intercon_0/M[add_master_interface]_AXI
    ext_spi_clk $ps_name/FCLK_CLK0
    s_axi_aclk $ps_name/FCLK_CLK0
    s_axi_aresetn proc_sys_reset_0/peripheral_aresetn
  }
  create_bd_addr_seg -range [get_memory_range axi_spi] -offset [get_memory_offset axi_spi] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs axi_spi0/AXI_LITE/Reg] SEG_axi_spi0_Reg
  connect_bd_net [get_bd_ports user_spi_sck] [get_bd_pins axi_spi0/sck_o]
  connect_bd_net [get_bd_pins axi_spi0/sck_i] [get_bd_pins axi_spi0/sck_o]
  connect_bd_net [get_bd_ports user_spi_ss] [get_bd_pins axi_spi0/ss_o]
  connect_bd_net [get_bd_pins axi_spi0/ss_i] [get_bd_pins axi_spi0/ss_o]
  connect_bd_net [get_bd_pins axi_spi0/io1_i] [get_bd_ports user_spi_miso] 
  connect_bd_net [get_bd_pins axi_spi0/io0_i] [get_bd_pins axi_spi0/io0_o]
  connect_bd_net [get_bd_ports user_spi_mosi] [get_bd_pins axi_spi0/io0_o]

connect_pin ps_0/IRQ_F2P [get_concat_pin [list xadc_wiz_0/ip2intc_irpt axi_iic/iic2intc_irpt axi_spi0/ip2intc_irpt data_axis_fifo/interrupt tx_axis_fifo/interrupt  axi_uartlite_0/interrupt ] interrupt_vec] 
