create_clock -period 20.000 [get_ports VCXO_CLK]

create_clock -period 78.125 -name ADC_SCLK -waveform {0.000 39.063} [get_ports ADC_SCLK]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {ADC_SCLK_IBUF}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {VCXO_CLK_IBUF}]
