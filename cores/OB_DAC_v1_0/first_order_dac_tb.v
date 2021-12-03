`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 40
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.

module first_order_dac_tb;
	// Inputs
	reg i_clk;
	reg i_res;
    reg i_ce;
	reg [15:0] i_func;


	// Outputs
	wire o_DAC;

	
	// Testvars for runlength-testing

	integer i;
	// Instantiate the Unit Under Test (UUT)
	first_order_dac uut (
		.i_clk(i_clk), 
		.i_res(i_res),
		.i_ce(i_ce),
		.i_func(i_func),
		.o_DAC(o_DAC)

	);



	always #(`BIT_TIME / 2) i_clk = ~i_clk;


	initial begin
		// Initialize Inputs
		i_clk = 1;
		i_res = 0;
		i_func = 0;
		i_ce = 1;


		// Wait 100 ns for global reset to finish
		#100
		i_res = 1;

		#(`BIT_TIME)
		i_func = 80;
		
        #(`BIT_TIME*1000)
		i_func = 31766;
		 #(`BIT_TIME*1000)
		i_func = 33770;
		 #(`BIT_TIME*1000)
		i_func = 65080;
        #(`BIT_TIME*1000)






        
	    $finish;
		end
	    

	
      
endmodule

