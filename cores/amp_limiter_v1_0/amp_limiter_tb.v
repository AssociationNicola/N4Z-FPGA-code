`timescale 1ns / 1ps

`define BIT_TIME 10
`define EBIT_TIME 40
//

module amp_limiter_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [15:0] amplitude;
    reg valid;

	// Outputs
	wire [15:0] limited_amp;

	

	integer i;
	// Instantiate the Unit Under Test (UUT)
	amp_limiter uut (
		.clk(clk), 
		.rst(rst),
		.valid(valid),
		.amplitude(amplitude),
		.limited_amp(limited_amp)
		
	);



	always #(`BIT_TIME / 2) clk = ~clk;

  always begin
     #(`EBIT_TIME) valid = 1;
     #(`BIT_TIME) valid=0;
  
  end




	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		amplitude = 0;


		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;

		#(`BIT_TIME)
		amplitude = 480;
		#(`EBIT_TIME*10)
		for (i = 0; i < 20000; i = i + 10) begin

				#`BIT_TIME

                amplitude = i;

		end
		amplitude =0;
		#(`EBIT_TIME*10)
		
		for (i = 0; i < 53000; i = i + 10) begin

				#`BIT_TIME

                amplitude = i;

		end
		
		
		
        rst = 0;
        
		$finish;

	end
      
endmodule

