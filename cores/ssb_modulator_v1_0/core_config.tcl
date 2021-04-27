set display_name {SSB Modulator}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

set_property VENDOR {GN} $core
set_property VENDOR_DISPLAY_NAME {GN} $core
set_property COMPANY_URL {http://www.grahamnaylor.net} $core

core_parameter NBITS {NBITS} {Number of bits of the accumulator (ssb_freq = freq_val*fc/ 2^NBITS)}

