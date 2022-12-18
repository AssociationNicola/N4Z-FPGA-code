`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 50
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.
//  input wire clk,
//  input wire rst,

//  input wire cic_i_pulse,

//  input wire signed [NBITS-1:0] amplitude,
//  output reg signed [NBITS-1:0] average,
//  output reg valid,
//  output reg signed [NBITS+ABITS-1:0] accumulator




module averager_tb;

	// Inputs
	reg clk;
	reg rst;
	reg signed [15:0] amplitude;
    reg cic_40_pulse;


	// Outputs
	wire signed [15:0] average;
	wire valid;
	wire signed [17:0] accumulator;




	
	// Testvars for runlength-testing


	// Instantiate the Unit Under Test (UUT)
	averager uut (
		.clk(clk), 
		.rst(rst),
		.amplitude(amplitude),
		.cic_40_pulse(cic_40_pulse),
		.average(average),
		.valid(valid),
		.accumulator(accumulator)
		
	);



  parameter CLK_PERIOD = 80;

	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		amplitude = 0;
		cic_40_pulse = 0;

		// Wait 100 ns for global reset to finish
		#(10*CLK_PERIOD);
		rst = 0;

		#(CLK_PERIOD)
		amplitude = 1080;
		#(12500*CLK_PERIOD)
		amplitude = -280;
		#(20000000*CLK_PERIOD)
		amplitude = 108;






        
		$finish;

	end

always begin
  #(311*CLK_PERIOD)
  cic_40_pulse=1;
  #(CLK_PERIOD)
  cic_40_pulse=0;

  end
  
  
  always #(CLK_PERIOD/2) clk = ~clk;


      
endmodule

