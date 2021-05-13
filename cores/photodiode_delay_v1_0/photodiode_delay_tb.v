`timescale 1ns / 1ps

`define BIT_TIME 10
//100MHz clock
`define D_TIME 4096
`define delay0_TIME 4096
// Purpose: try all 2-symbol sequences
// and ensure that there are no runs of 5 or more bits.

module photodiode_delay_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [4:0] PD;



	// Outputs
	wire [11:0] PD4_delay;
	wire [31:0] PD_delays;
    wire button_activate;
	
	integer i;
	// Instantiate the Unit Under Test (UUT)
	photodiode_delay uut (
		.clk(clk), 
		.rst(rst),
		.PD(PD),
		.PD4_delay(PD4_delay),
		.PD_delays(PD_delays),
        .button_activate(button_activate)
	);



	always #(`BIT_TIME / 2) clk = ~clk;


	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;


		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;

		#(`BIT_TIME)
		PD = 0;
		for (i = 0; i < 9000; i = i + 1) begin

		#(`delay0_TIME)
                PD = 1;
		#(`delay0_TIME/2)
                PD = 3;
		#(`delay0_TIME/2)
                PD = 7;
		#`delay0_TIME
                PD = 15;
		#`delay0_TIME
                PD = 31;
		#(`delay0_TIME * 6)
                PD = 0;


		end
        rst = 0;
        
		$finish;

	end
      
endmodule

