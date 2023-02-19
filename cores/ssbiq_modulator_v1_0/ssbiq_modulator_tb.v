`timescale 1 ns / 1 ps





module ssbiq_modulator_tb();
  reg clk;
  reg rst;
  reg [13:0] delta_phase;
  reg [29:0] ssb_freq;
  reg [26:0] amplitude;
  reg set_qpsk;
  reg [26:0] qpsk_phase;
  reg stdby;
  wire DRV0;
  wire DRV1;



  ssbiq_modulator  #()
  DUT (
    .clk(clk),
	.rst(rst),
	  .delta_phase(delta_phase),
	  .ssb_freq(ssb_freq),
	  .amplitude(amplitude),
	  .set_qpsk(set_qpsk),
      .qpsk_phase(qpsk_phase),
	  .stdby(stdby),
	  .DRV0(DRV0),
	  .DRV1(DRV1)
	      
  );

  parameter CLK_PERIOD = 16;



  initial begin
    clk = 1;
    rst = 1;  
    stdby=0;
    set_qpsk=0;
    qpsk_phase = 0;  
	  #(10*CLK_PERIOD) delta_phase = 0;
	  ssb_freq=178176 * 2**12;
	  amplitude=325000;
	  #(1*CLK_PERIOD) rst = 0;
	  #(1000*CLK_PERIOD) amplitude=325000;
	  #(10000*CLK_PERIOD) delta_phase=16000;
	  #(10000*CLK_PERIOD) set_qpsk=1;

	  #(10000*CLK_PERIOD) qpsk_phase=2**24;

	  #(10000*CLK_PERIOD) qpsk_phase=2**25 + 2**24;

	  #(10000*CLK_PERIOD) qpsk_phase=2**24  + 2**26;

	  #(10000*CLK_PERIOD) qpsk_phase=2**25 + 2**24  + 2**26;

	  #(10000*CLK_PERIOD) qpsk_phase=2**25 + 2**24;

	  #(10000*CLK_PERIOD) qpsk_phase= 2**24;


       #(1000*CLK_PERIOD) stdby=1;
	  #(100*CLK_PERIOD);
    $finish;
  end
  
  always #(CLK_PERIOD/2) begin
  $display($time, " dout='h%x", DUT.accumulator);
  clk = ~clk;
  end

endmodule

