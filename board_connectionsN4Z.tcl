#  set IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC ]
  set btns [ create_bd_port -dir I -from 1 -to 0 btns ]
#  set ck_inner_io [ create_bd_port -dir I -from 13 -to 0 ck_inner_io ]
#Note inner (inputs) is the outer row and outer (outputs) is the inner row on the board
#  set ck_outer_io [ create_bd_port -dir O -from 15 -to 0 ck_outer_io ]

  set led0 [ create_bd_port -dir O -from 2 -to 0 led0 ]
  set led1 [ create_bd_port -dir O -from 2 -to 0 led1 ]
#  set spi_clk_i [ create_bd_port -dir I spi_clk_i ]
#  set spi_clk_o [ create_bd_port -dir O spi_clk_o ]
#  set spi_csn_i [ create_bd_port -dir I -from 0 -to 0 spi_csn_i ]
#  set spi_csn_o [ create_bd_port -dir O -from 0 -to 0 spi_csn_o ]
#  set spi_sdi_i [ create_bd_port -dir I spi_sdi_i ]
#  set spi_sdo_i [ create_bd_port -dir I spi_sdo_i ]
#  set spi_sdo_o [ create_bd_port -dir O spi_sdo_o ]
#Unpopulated J1 connector pins are outputs
  set user_dio [ create_bd_port -dir O -from 11 -to 0 user_dio ]

  set Vp_Vn_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn_0 ]

  set_property "ip_repo_paths" "[concat [get_property ip_repo_paths [current_project]] [file normalize $board_path/ip]]" "[current_project]"
  update_ip_catalog -rebuild 


  cell xilinx.com:ip:xadc_wiz:3.3 xadc_wiz_0  {
   CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} 
   CHANNEL_ENABLE_VAUXP12_VAUXN12 {true} 
   CHANNEL_ENABLE_VAUXP13_VAUXN13 {true} 
   CHANNEL_ENABLE_VAUXP15_VAUXN15 {true} 
   CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} 
   CHANNEL_ENABLE_VAUXP5_VAUXN5 {true} 
   CHANNEL_ENABLE_VAUXP6_VAUXN6 {true} 
   CHANNEL_ENABLE_VAUXP8_VAUXN8 {true} 
   CHANNEL_ENABLE_VAUXP9_VAUXN9 {true} 
   CHANNEL_ENABLE_VP_VN {true} 
   ENABLE_VCCDDRO_ALARM {false} 
   ENABLE_VCCPAUX_ALARM {false} 
   ENABLE_VCCPINT_ALARM {false} 
   EXTERNAL_MUX_CHANNEL {VP_VN} 
   OT_ALARM {false} 
   SEQUENCER_MODE {Continuous} 
   SINGLE_CHANNEL_SELECTION {TEMPERATURE} 
   USER_TEMP_ALARM {false} 
   VCCAUX_ALARM {false} 
   VCCINT_ALARM {false} 
   XADC_STARUP_SELECTION {channel_sequencer} 
  } {
    s_axi_lite axi_mem_intercon_0/M[add_master_interface]_AXI
    s_axi_aclk $ps_name/FCLK_CLK0
    s_axi_aresetn proc_sys_reset_0/peripheral_aresetn
    Vp_Vn Vp_Vn_0
  }

#  # Create instance: PWM_0, and set properties
#  cell digilentinc.com:IP:PWM:2.0 PWM_0 {
#    NUM_PWM {3}
#  } {
#    PWM_AXI axi_mem_intercon_0/M[add_master_interface]_AXI
#    pwm_axi_aclk $ps_name/FCLK_CLK0
#    pwm_axi_aresetn proc_sys_reset_0/peripheral_aresetn
#    pwm led0
#  }
#
#  # Create instance: PWM_1, and set properties
#  cell digilentinc.com:IP:PWM:2.0 PWM_1 {
#    NUM_PWM {3}
#  } {
#    PWM_AXI axi_mem_intercon_0/M[add_master_interface]_AXI
#    pwm_axi_aclk $ps_name/FCLK_CLK0
#    pwm_axi_aresetn proc_sys_reset_0/peripheral_aresetn
#    pwm led1
#  }
#
#  # Create instance: axi_iic_0, and set properties
#  cell xilinx.com:ip:axi_iic:2.0 axi_iic {
#  } {
#    S_AXI axi_mem_intercon_0/M[add_master_interface]_AXI
#    s_axi_aclk $ps_name/FCLK_CLK0
#    s_axi_aresetn proc_sys_reset_0/peripheral_aresetn
#    IIC IIC
#  }

#  # Create instance: axi_spi, and set properties
#  cell xilinx.com:ip:axi_quad_spi:3.2 axi_spi {
#   C_USE_STARTUP {0} 
#   C_USE_STARTUP_INT {0} 
#  } {
#    AXI_LITE axi_mem_intercon_0/M[add_master_interface]_AXI
#    ext_spi_clk $ps_name/FCLK_CLK0
#    s_axi_aclk $ps_name/FCLK_CLK0
#    s_axi_aresetn proc_sys_reset_0/peripheral_aresetn
#  }
#  connect_bd_net -net spi_clk_i_1 [get_bd_ports spi_clk_i] [get_bd_pins axi_spi/sck_i]
#  connect_bd_net -net spi_csn_i_1 [get_bd_ports spi_csn_i] [get_bd_pins axi_spi/ss_i]
#  connect_bd_net -net spi_sdi_i_1 [get_bd_ports spi_sdi_i] [get_bd_pins axi_spi/io1_i]
#  connect_bd_net -net spi_sdo_i_1 [get_bd_ports spi_sdo_i] [get_bd_pins axi_spi/io0_i]
#  connect_bd_net -net axi_spi_io0_o [get_bd_ports spi_sdo_o] [get_bd_pins axi_spi/io0_o]
#  connect_bd_net -net axi_spi_sck_o [get_bd_ports spi_clk_o] [get_bd_pins axi_spi/sck_o]
#  connect_bd_net -net axi_spi_ss_o [get_bd_ports spi_csn_o] [get_bd_pins axi_spi/ss_o]

#  create_bd_addr_seg -range [get_memory_range led0] -offset [get_memory_offset led0] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs PWM_0/PWM_AXI/PWM_AXI_reg] SEG_PWM_0_PWM_AXI_reg
#  create_bd_addr_seg -range [get_memory_range led1] -offset [get_memory_offset led1] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs PWM_1/PWM_AXI/PWM_AXI_reg] SEG_PWM_1_PWM_AXI_reg
#  create_bd_addr_seg -range [get_memory_range ck_iic] -offset [get_memory_offset ck_iic] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs axi_iic/S_AXI/Reg] SEG_axi_iic_Reg
#  create_bd_addr_seg -range [get_memory_range ck_spi] -offset [get_memory_offset ck_spi] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs axi_spi/AXI_LITE/Reg] SEG_axi_spi_Reg
  create_bd_addr_seg -range [get_memory_range xadc] -offset [get_memory_offset xadc] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs xadc_wiz_0/s_axi_lite/Reg] SEG_xadc_wiz_0_Reg


