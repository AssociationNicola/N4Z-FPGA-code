set display_name {photodiode_delay}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

set_property VENDOR {GN} $core
set_property VENDOR_DISPLAY_NAME {GN} $core
set_property COMPANY_URL {http://www.grahamnaylor.net} $core

core_parameter NBITS {NBITS} {Number of bits in the counter}
core_parameter ABITS {ABITS} {Number of bits accumulating}
