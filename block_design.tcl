# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
source $sdk_path/fpga/lib/starting_point.tcl

# Add config and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts
source $project_path/board_connectionsN4Z_v2.tcl
source $board_path/analogue.tcl
#source $board_path/pmods.tcl

#create_bd_port -dir I -from 7 -to 0 pmod_ja
create_bd_port -dir O -from 7 -to 0 pmod_jb

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 data_clk_in

create_bd_port -dir O CS5340_MCLK
create_bd_port -dir O Button_Active
create_bd_port -dir O CS5340_NRST
create_bd_port -dir O SSB_Out0
create_bd_port -dir O SSB_Out1
create_bd_port -dir O BUSY
create_bd_port -dir O DRST
create_bd_port -dir O D_C
create_bd_port -dir O ECS
create_bd_port -dir O ENA
create_bd_port -dir I -from 4 -to 0 PD
create_bd_port -dir O LCD_E
create_bd_port -dir O LCD_RW
create_bd_port -dir O LCD_RS
create_bd_port -dir O LCD_V0
create_bd_port -dir O -from 7 -to 0 LCD

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

#Temporarily connect PD signals to LCD signals
#connect_port_pin LCD [get_concat_pin [list PD1 PD2 PD3 PD4 PD5 [get_constant_pin 0 3] ] ]


# Connect LEDs to config register
connect_port_pin led0 [get_slice_pin ctl/led 2 0]
connect_port_pin led1 [get_slice_pin ctl/led 5 3]



#Note the user_dio pins are offset 1 as they seem to need to start from 0!
connect_port_pin user_dio [get_slice_pin [ctl_pin user_io] 6 0]


connect_pin [sts_pin ck_inner_io] ctl/ssb_tx_frequency


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
    reset [get_constant_pin 0 1]
}

cell xilinx.com:ip:clk_wiz clk_wiz_1 {

CLKOUT1_REQUESTED_OUT_FREQ 65.536 
MMCM_DIVCLK_DIVIDE 2 
MMCM_CLKFBOUT_MULT_F 16.875 
MMCM_CLKOUT0_DIVIDE_F 12.875 
CLKOUT1_JITTER 188.876 
CLKOUT1_PHASE_ERROR 137.238



} {
    clk_in1 ps_0/fclk_clk0
    reset [get_constant_pin 0 1]
}

#clk_wiz_1/clk_out1 is at 65.536MHz ie 8192 (2^13) times 8kHz


# Rename clocks - adc_clk in this is 12.8MHz - ie 64x Sample rate of 200ksps and about 1/8 of the ps clock
set adc_clk CS5340_SCLK

# Add processor system reset synchronous to adc clock
set rst_adc_clk_name proc_sys_reset_adc_clk
cell xilinx.com:ip:proc_sys_reset:5.0 $rst_adc_clk_name {} {
  ext_reset_in $ps_name/FCLK_RESET0_N
  slowest_sync_clk $adc_clk
}




cell TE:user:i2s_rx:1.0 adc_reader {

} {
Clock   CS5340_SCLK
Reset  proc_sys_reset_adc_clk/peripheral_reset
LRClock  CS5340_LRCLK
Data  CS5340_SDout
}


#Insert stuff from decimator





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

#####################################
# Complex multiply
#####################################

    cell pavel-demin:user:axis_lfsr:1.0 lfsr {} {
        aclk $adc_clk
        aresetn $rst_adc_clk_name/peripheral_aresetn
    }


# Maybe need to strobe tvalid with [get_and_pin adc_reader/IsUpdate adc_reader/IsLeft LeftValid ] and use LeftValid/res or something for the clock convertor - but then what is the clock convertor for? Maybe it should be used after FIR??
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




# Use AXI Stream clock converter (ADC clock -> FPGA clock)
set intercon_idx 0


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
  Input_Data_Width 24
  Quantization Truncation
  Output_Data_Width 32
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid complex_mult/m_axis_dout_tvalid
  s_axis_data_tdata [get_slice_pin complex_mult/m_axis_dout_tdata 23 0]


}

cell xilinx.com:ip:cic_compiler:4.0 cic_q {
  Filter_Type Decimation
  Number_Of_Stages $n_stages
  Fixed_Or_Initial_Rate $dec_rate
  Differential_Delay $diff_delay
  Input_Sample_Frequency [expr [get_parameter adc_clk] / 64000000.]
  Clock_Frequency [expr [get_parameter adc_clk] / 1000000.]
  Input_Data_Width 24
  Quantization Truncation
  Output_Data_Width 32
  Use_Xtreme_DSP_Slice false
} {
  aclk $adc_clk
  s_axis_data_tvalid complex_mult/m_axis_dout_tvalid
  s_axis_data_tdata [get_slice_pin complex_mult/m_axis_dout_tdata 47 24]


}


#BT mic input (first add an axi interconnect allocation):
set idx [add_master_interface $intercon_idx]
cell xilinx.com:ip:axi_fifo_mm_s:4.1 tx_axis_fifo {
  C_USE_RX_DATA 0
  C_USE_TX_CTRL 0
  C_USE_TX_CUT_THROUGH true

  C_TX_FIFO_DEPTH 2048
  C_TX_FIFO_PF_THRESHOLD 2000
  C_TX_FIFO_PE_THRESHOLD 6
} {
  s_axi_aclk [set ps_clk$intercon_idx]
  s_axi_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  S_AXI [set interconnect_${intercon_idx}_name]/M${idx}_AXI

}



cell xilinx.com:ip:axis_clock_converter:1.1 tx_clock_converter {
  TDATA_NUM_BYTES 4
} {
  s_axis_tdata tx_axis_fifo/axi_str_txd_tdata  
  s_axis_tvalid tx_axis_fifo/axi_str_txd_tvalid
  s_axis_tready tx_axis_fifo/axi_str_txd_tready
  m_axis_tready cic_i/m_axis_data_tvalid
  m_axis_aresetn $rst_adc_clk_name/peripheral_aresetn
  s_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  m_axis_aclk $adc_clk
  s_axis_aclk [set ps_clk$intercon_idx]
}




cell koheron:user:latched_mux:1.0 data_for_fir_i {
            WIDTH 32
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 4 4]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list cic_i/m_axis_data_tdata  tx_clock_converter/m_axis_tdata] fir_i_inputs ]

        }

cell koheron:user:latched_mux:1.0 data_for_fir_q {
            WIDTH 32
    	    N_INPUTS 2
            SEL_WIDTH 1
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 4 4]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list cic_q/m_axis_data_tdata  tx_clock_converter/m_axis_tdata] fir_q_inputs ]

        }






set dec_rate_fir [get_parameter fir_decimation_rate]
#Data input rate at 40kHz paced by the cic
set fidi [open $project_path/128tap_i.txt r]
gets $fidi charsi
set fir_coeffs_i $charsi
puts stdout fir_coeffs_i

set fidq [open $project_path/128tap_q.txt r]
gets $fidq charsq
set fir_coeffs_q $charsq
puts stdout fir_coeffs_q
#was: [exec python $project_path/fir.py $n_stages $dec_rate $diff_delay print]

#removed:
#  Quantization Maximize_Dynamic_Range 
#  Coefficient_Fractional_Bits 33 
#  Coefficient_Structure Inferred 



cell xilinx.com:ip:fir_compiler:7.2 fir_i {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter fclk0] / 1000000.]
  Coefficient_Width 32
  Data_Width 32
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 32
  Decimation_Rate $dec_rate_fir
  BestPrecision true

  CoefficientVector [subst {{$fir_coeffs_i}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_i/m_axis_data_tvalid
  s_axis_data_tdata data_for_fir_i/dout
}

cell xilinx.com:ip:fir_compiler:7.2 fir_q {
  Filter_Type Decimation
  Sample_Frequency [expr [get_parameter adc_clk] / 1000000. / $dec_rate]
  Clock_Frequency [expr [get_parameter fclk0] / 1000000.]
  Coefficient_Width 32
  Data_Width 32
  Output_Rounding_Mode Convergent_Rounding_to_Even
  Output_Width 32
  Decimation_Rate $dec_rate_fir
  BestPrecision true

  CoefficientVector [subst {{$fir_coeffs_q}}]
} {
  aclk $adc_clk
  s_axis_data_tvalid cic_q/m_axis_data_tvalid
  s_axis_data_tdata data_for_fir_q/dout
}

cell xilinx.com:ip:c_addsub:12.0 c_addsub_0 {
B_Width.VALUE_SRC USER 
A_Width.VALUE_SRC USER 
A_Type.VALUE_SRC USER

Implementation Fabric 
A_Width 32 
B_Width 32 
Add_Mode Add_Subtract 
Out_Width 32 
CE false 
Out_Width 32 
Latency 1 
B_Value 00000000000000000000000000000000

} {
A fir_i/m_axis_data_tdata
B fir_q/m_axis_data_tdata
CLK $adc_clk
ADD [get_slice_pin ctl/control 0 0]
}



cell xilinx.com:ip:cordic:6.0 cordic_ssb {
    Functional_Selection Translate
    Pipelining_Mode Maximum
    Phase_Format Scaled_Radians
    Input_Width 32
    Output_Width 16
    Round_Mode Round_Pos_Neg_Inf
} {
    aclk  $adc_clk
    s_axis_cartesian_tvalid fir_i/m_axis_data_tvalid
    s_axis_cartesian_tdata [get_concat_pin [list fir_i/m_axis_data_tdata  fir_q/m_axis_data_tdata ] concat_audio_iq]

}




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
B_Value 00000000000000000000000000000000

} {
A [get_Q_pin [get_slice_pin cordic_ssb/m_axis_dout_tdata 31 16] 1 cordic_ssb/m_axis_dout_tvalid $adc_clk cordic_phase_latched_8k ]
B [get_Q_pin cordic_phase_latched_8k/Q 1 cordic_ssb/m_axis_dout_tvalid $adc_clk]
CLK $adc_clk

}

#Insert averager here !!!!!!!!!!!!!!!!!!!!
cell GN:user:averager:1.0 level_monitor {

} {
clk $adc_clk
next cordic_ssb/m_axis_dout_tvalid
rst $rst_adc_clk_name/peripheral_reset
amplitude [get_Q_pin [get_slice_pin cordic_ssb/m_axis_dout_tdata 15 0] 1 cordic_ssb/m_axis_dout_tvalid $adc_clk cordic_amplitude_latched_8k ]
}


connect_pin [sts_pin average_amplitude] [get_concat_pin [list level_monitor/average [get_constant_pin 0 16]] padded_average]
connect_pin [sts_pin max_amplitude] [get_concat_pin [list level_monitor/max_val [get_constant_pin 0 16]] padded_max]


#clk_wiz_1/clk_out1 is at 8.192MHz ie 1024 (2^10) times 8kHz
#Amplitude adjusted 31/1/21 to get the maximum dynamic range from the SSB modulation


cell GN:user:ssb_modulator:1.0 ssb_tx {
NBITS 24
} {
 clk clk_wiz_1/clk_out1
 rst $rst_adc_clk_name/peripheral_reset
 delta_phase [get_slice_pin diff_phase/S 13 0] 
 ssb_freq  [get_slice_pin ctl/ssb_tx_frequency 17 0] 
 amplitude [get_concat_pin  [list [get_constant_pin 0 12] [get_slice_pin cordic_ssb/m_axis_dout_tdata 14 0] ] padded_amplitude]
 stdby [get_not_pin [get_slice_pin ctl/control 1 1] ]
}

cell GN:user:photodiode_delay:1.0 pd_delays {
} {
 clk ps_0/fclk_clk0
 rst [get_slice_pin ctl/control 30 30]
 
}

connect_port_pin PD pd_delays/PD
#connect_bd_net [get_bd_pins concat_PD1_PD2_PD3_PD4_PD5/dout] [get_bd_pins pd_delays/PD]

connect_pin [get_concat_pin [list pd_delays/PD4_delay [get_constant_pin 0 20]]] sts/pd4_delay
connect_pin pd_delays/PD_delays  sts/pd_delays
connect_port_pin Button_Active pd_delays/button_activate

connect_port_pin BUSY [get_slice_pin ctl/display 0 0]
connect_port_pin DRST [get_slice_pin ctl/display 1 1]
connect_port_pin  D_C [get_slice_pin ctl/display 2 2]
connect_port_pin  ECS [get_slice_pin ctl/display 3 3]
connect_port_pin  ENA [get_slice_pin ctl/display 4 4]
connect_port_pin  LCD [get_slice_pin ctl/lcd 7 0]
connect_port_pin  LCD_E [get_slice_pin ctl/lcd 8 8]
connect_port_pin  LCD_RW [get_slice_pin ctl/lcd 9 9]
connect_port_pin  LCD_RS [get_slice_pin ctl/lcd 10 10]
connect_port_pin  LCD_V0 [get_slice_pin ctl/lcd 11 11]
connect_port_pin SSB_Out0 ssb_tx/DRV0 
connect_port_pin SSB_Out1 ssb_tx/DRV1 

#These mux inputs should be on $adc_clk
set idx [add_master_interface $intercon_idx]
cell koheron:user:latched_mux:1.0 data_for_fifo {
            WIDTH 32
    	    N_INPUTS 4
            SEL_WIDTH 2
        } {
            clk  $adc_clk 
            sel [get_slice_pin ctl/control 3 2]
            clken [get_constant_pin 1 1]
            din [get_concat_pin [list c_addsub_0/S cordic_ssb/m_axis_dout_tdata  [get_concat_pin [list diff_phase/S [get_constant_pin 0 15] ]  ] [get_concat_pin [list [get_slice_pin fir_i/m_axis_data_tdata 29 14] [get_slice_pin fir_q/m_axis_data_tdata 29 14]  ] i_and_q_data ] ] data_options ]

        }




#Need to add above  [NBITS-11:0] delta_phase and  [NBITS-1:0] amplitude plus tx_low on  stdby,
#Need to add tx fifo to receive BT mic input.

cell xilinx.com:ip:axis_clock_converter:1.1 adc_clock_converter {
  TDATA_NUM_BYTES 4
} {
  s_axis_tdata data_for_fifo/dout
  s_axis_tvalid fir_i/m_axis_data_tvalid
  s_axis_aresetn $rst_adc_clk_name/peripheral_aresetn
  m_axis_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  s_axis_aclk $adc_clk
  m_axis_aclk [set ps_clk$intercon_idx]
}




# Add AXI stream FIFO
cell xilinx.com:ip:axi_fifo_mm_s:4.1 data_axis_fifo {
  C_USE_TX_DATA 0
  C_USE_TX_CTRL 0
  C_USE_RX_CUT_THROUGH true
  C_RX_FIFO_DEPTH 2048
  C_RX_FIFO_PF_THRESHOLD 2000
} {
  s_axi_aclk [set ps_clk$intercon_idx]
  s_axi_aresetn [set rst${intercon_idx}_name]/peripheral_aresetn
  S_AXI [set interconnect_${intercon_idx}_name]/M${idx}_AXI
  axi_str_rxd_tvalid adc_clock_converter/m_axis_tvalid
  axi_str_rxd_tdata   adc_clock_converter/m_axis_tdata
}


#Convert the signed number to an offset unsigned number for the DAC (only use lowest 16 bits)
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
A [get_slice_pin adc_clock_converter/m_axis_tdata 31 16]
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
            din [get_concat_pin [list  [get_slice_pin twos_Comp_Unsigned/S 15 0] [get_slice_pin ctl/user_io 15 0]]]

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

#connect_port_pin Button_Active [get_slice_pin ctl/control 31 31]


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

  connect_pin ps_0/IRQ_F2P [get_concat_pin [list xadc_wiz_0/ip2intc_irpt axi_iic/iic2intc_irpt axi_spi0/ip2intc_irpt data_axis_fifo/interrupt tx_axis_fifo/interrupt ] ] 
