create_clock -period 10 [get_ports data_clk_in_clk_p]
set_input_jitter [get_clocks -of_objects [get_ports data_clk_in_clk_p] 0.1
