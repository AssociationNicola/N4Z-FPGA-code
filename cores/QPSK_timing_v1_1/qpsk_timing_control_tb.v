`timescale 1 ns / 1 ps


module timing_control_tb();

  reg			cic_40_pulse;
  reg    		rst;

  reg			clk;


   wire [15:0]		cic_pulse_counter;





  timing_control #() 
  DUT (
    .cic_40_pulse(cic_40_pulse),
    .rst(rst),
    .clk(clk),

    .cic_pulse_counter(cic_pulse_counter)


  );

  parameter CLK_PERIOD = 80;

  initial begin
    clk = 1;
    rst = 1;
  cic_40_pulse=0;

  #(400*CLK_PERIOD) 
  rst = 0;  
    #(10000*64*CLK_PERIOD)
    $finish;
  end

always begin
  #(319*CLK_PERIOD)
  cic_40_pulse=1;
  #(CLK_PERIOD)
  cic_40_pulse=0;

  end
  

  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule


