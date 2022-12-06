`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 50
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.

module averager_tb;

	// Inputs
	reg clk;
	reg rst;
	reg signed [15:0] amplitude;
    reg load_val;
    reg msf_carrier_pulse;
    reg one_sec_marker;
    reg [12:0] number_msf_periods;

	// Outputs
	wire signed [15:0] average;
	wire valid;
	wire signed [23:0] accumulator;
	wire[12:0] counter;



	
	// Testvars for runlength-testing


	// Instantiate the Unit Under Test (UUT)
	averager uut (
		.clk(clk), 
		.rst(rst),
		.amplitude(amplitude),
		.load_val(load_val),
        .msf_carrier_pulse(msf_carrier_pulse),
        .one_sec_marker(one_sec_marker),
        .number_msf_periods(number_msf_periods),
		.average(average),
		.valid(valid),
		.counter(counter),
		.accumulator(accumulator)
		
	);



  parameter CLK_PERIOD = 80;

	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		amplitude = 0;
		load_val = 0;
        one_sec_marker=0;
        number_msf_periods=16;
  msf_carrier_pulse=0;
		// Wait 100 ns for global reset to finish
		#(10*CLK_PERIOD);
		rst = 0;

		#(CLK_PERIOD)
		amplitude = 1080;
		#(20000000*CLK_PERIOD)
		amplitude = 108;






        
		$finish;

	end

always begin
  #(164*CLK_PERIOD)
  msf_carrier_pulse=1;
  #(CLK_PERIOD)
  msf_carrier_pulse=0;

  end
  
always begin
  #(500*CLK_PERIOD)
  load_val=1;
  #(CLK_PERIOD)
  load_val=0;

  end
  
 always begin 
  one_sec_marker=0;
  #(2722335*CLK_PERIOD)
  one_sec_marker=1;
  #(165*CLK_PERIOD);
  end
  
  always #(CLK_PERIOD/2) clk = ~clk;


      
endmodule

