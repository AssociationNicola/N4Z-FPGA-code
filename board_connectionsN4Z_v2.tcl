  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 ck_iic 
  set btns [ create_bd_port -dir I -from 1 -to 0 btns ]

  create_bd_port -dir O ck_spi_mosi 
  create_bd_port -dir O ck_spi_ss 
  create_bd_port -dir O ck_spi_sck 
  create_bd_port -dir I ck_spi_miso 
  
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

  # Create instance: axi_iic_0, and set properties
  cell xilinx.com:ip:axi_iic:2.0 axi_iic {
  } {
    S_AXI axi_mem_intercon_0/M[add_master_interface]_AXI
    s_axi_aclk $ps_name/FCLK_CLK0
    s_axi_aresetn proc_sys_reset_0/peripheral_aresetn
    IIC ck_iic
  }

  set_cell_props ps_0 {
    pcw_spi0_peripheral_enable 1
    PCW_USE_FABRIC_INTERRUPT {1} 
    PCW_IRQ_F2P_INTR {1}
  }

  connect_bd_net [get_bd_ports ck_spi_sck] [get_bd_pins $ps_name/SPI0_SCLK_O]
  connect_bd_net [get_bd_pins $ps_name/SPI0_SCLK_I] [get_bd_pins $ps_name/SPI0_SCLK_O]
  connect_bd_net [get_bd_ports ck_spi_ss] [get_bd_pins $ps_name/SPI0_SS_O]
  connect_bd_net [get_bd_pins $ps_name/SPI0_MISO_I] [get_bd_ports ck_spi_miso] 
  connect_bd_net [get_bd_pins $ps_name/SPI0_MOSI_I] [get_bd_pins $ps_name/SPI0_MOSI_O]
  connect_bd_net [get_bd_ports ck_spi_mosi] [get_bd_pins $ps_name/SPI0_MOSI_O]

  create_bd_addr_seg -range [get_memory_range ck_iic] -offset [get_memory_offset ck_iic] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs axi_iic/S_AXI/Reg] SEG_axi_iic_Reg
  create_bd_addr_seg -range [get_memory_range xadc] -offset [get_memory_offset xadc] [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs xadc_wiz_0/s_axi_lite/Reg] SEG_xadc_wiz_0_Reg


