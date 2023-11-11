## This file is a general .xdc for the Cora Z7-07S Rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## PL System Clock
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
#create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];#set

## RGB LEDs
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {led0[0]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {led0[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {led0[2]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {led1[0]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {led1[1]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {led1[2]}]

## Buttons
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btns[0]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btns[1]}]

## Pmod Header JA
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[0]}]; #IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[1]}]; #IO_L17N_T2_34 Sch=ja_n[1]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[2]}]; #IO_L7P_T1_34 Sch=ja_p[2]
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[3]}]; #IO_L7N_T1_34 Sch=ja_n[2]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[4]}]; #IO_L12P_T1_MRCC_34 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[5]}]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[6]}]; #IO_L22P_T3_34 Sch=ja_p[4]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {pmod_ja[7]}]; #IO_L22N_T3_34 Sch=ja_n[4]

## Pmod Header JB
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[0]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[1]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[3]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[5]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[6]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {pmod_jb[7]}]

## Crypto SDA
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }];

## Dedicated Analog Inputs
set_property -dict {PACKAGE_PIN K9 IOSTANDARD LVCMOS33} [get_ports Vp_Vn_0_v_p]
set_property -dict {PACKAGE_PIN L10 IOSTANDARD LVCMOS33} [get_ports Vp_Vn_0_v_n]

## ChipKit Outer Digital Header
## Allow n side CC input to be single ended clock input for SCLK:
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {CS5340_SCLK_IBUF}]

set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports ADC_MCLK]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports ADC_SDout]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports ADC_NRST]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports PowerState]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports SSB_Out0]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports SSB_Out1]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports audio_speaker_p]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports Volume]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports audio_speaker_n]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports NShtdn]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports ADC_SCLK]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports VCXO]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports TestOut]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports P_Offn]

## ChipKit Inner Digital Header
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports ADC_LRCLK]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports TP_IRQ]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports RST]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports LCD_RS]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports LCD_CS]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports TP_CS]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports Uart_RX]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports Uart_TX]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports PTT]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports LED]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports Spare]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports TX_High]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports VCXO_CLK]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports NOVFL]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports NHPF]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports I2S]

## ChipKit SPI
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports ck_spi_miso]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports ck_spi_mosi]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports ck_spi_sck]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports ck_spi_ss]

## ChipKit I2C
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports ck_iic_scl_io]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports ck_iic_sda_io]

##Misc. ChipKit signals
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { ck_ioa }]; #IO_L7N_T1_AD2N_35 Sch=ck_ioa

## User Digital I/O Header J1
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {user_dio[0]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {user_dio[1]}]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports {user_dio[2]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33} [get_ports {user_dio[3]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {user_dio[4]}]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {user_dio[5]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports {user_dio[6]}]
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[7] }]; #IO_25_34 Sch=user_dio[8]
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[8] }]; #IO_L15N_T2_DQS_34 Sch=user_dio[9]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[9] }]; #IO_L16P_T2_34 Sch=user_dio[10]
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { user_dio[10] }]; #IO_L16N_T2_34 Sch=user_dio[11]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { user_dio[11] }]; #IO_L10P_T1_AD11P_35 Sch=user_dio[12]




set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports user_spi_mosi]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports {user_spi_ss[0]}]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { user_spi_ss[1] }]; #IO_L16P_T2_34 Sch=user_dio[10]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports user_spi_sck]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports user_spi_miso]


