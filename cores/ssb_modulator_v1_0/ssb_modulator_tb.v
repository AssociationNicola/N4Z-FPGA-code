`timescale 1 ns / 1 ps

module ssb_modulator_tb();
  reg clk;
  reg rst;
  reg [13:0] delta_phase;
  reg [17:0] ssb_freq;
  reg [23:0] amplitude;
  reg stdby;
  wire DRV0;
  wire DRV1;


  ssb_modulator #()
  DUT (
    .clk(clk),
	.rst(rst),
	  .delta_phase(delta_phase),
	  .ssb_freq(ssb_freq),
	  .amplitude(amplitude),
	  .stdby(stdby),
	  .DRV0(DRV0),
	  .DRV1(DRV1)
    
  );

  parameter CLK_PERIOD = 10;



  initial begin
    clk = 1;
    rst = 1;  
    stdby=0;  
	  #(10*CLK_PERIOD) delta_phase = 0;
	  ssb_freq=2**15;
	  amplitude=2**21;
	  #(1*CLK_PERIOD) rst = 0;
	  #(1500*CLK_PERIOD) amplitude=2**22;
	  #(1000*CLK_PERIOD) delta_phase = 2**10;

	  #(1000*CLK_PERIOD) stdby=1;
	  #(100*CLK_PERIOD);
    $finish;
  end
  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule

