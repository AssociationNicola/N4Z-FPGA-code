`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 40
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.

module averager_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [15:0] amplitude;
    reg next;

	// Outputs
	wire [15:0] average;
	wire [15:0] max_val;
	
	// Testvars for runlength-testing

	integer i;
	// Instantiate the Unit Under Test (UUT)
	averager uut (
		.clk(clk), 
		.rst(rst),
		.amplitude(amplitude),
		.next(next),
		.average(average),
		.max_val(max_val)
	);



	always #(`BIT_TIME / 2) clk = ~clk;


	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		amplitude = 0;
		next = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;

		#(`BIT_TIME)
		amplitude = 1080;
		for (i = 0; i < 256; i = i + 1) begin

				#`EBIT_TIME
				next =1;
                #`BIT_TIME
				next =0;

				#`EBIT_TIME
				amplitude = 1900;
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;

				amplitude = 1960;
			    next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;
				#`EBIT_TIME
				next =1;
                #`BIT_TIME
			    next=0;



		end
        rst = 0;
        
		$finish;

	end
      
endmodule

