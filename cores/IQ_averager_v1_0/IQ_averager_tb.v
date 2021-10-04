`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 50
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.

module averager_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] amplitude;
    reg load_val;

	// Outputs
	wire [31:0] average;
	wire valid;
	
	// Testvars for runlength-testing

	integer i;
	// Instantiate the Unit Under Test (UUT)
	averager uut (
		.clk(clk), 
		.rst(rst),
		.amplitude(amplitude),
		.load_val(load_val),
		.average(average),
		.valid(valid)
	);



	always #(`BIT_TIME / 2) clk = ~clk;


	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		amplitude = 0;
		load_val = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;

		#(`BIT_TIME)
		amplitude = 1080;
		for (i = 0; i < 500; i = i + 1) begin

				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
				load_val =0;

				#`EBIT_TIME
				amplitude = 1900;
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
                #`EBIT_TIME
				amplitude = 1960;
			    load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;
				#`EBIT_TIME
				load_val =1;
                #`BIT_TIME
			    load_val=0;



		end
        rst = 0;
        
		$finish;

	end
      
endmodule

