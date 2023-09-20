`timescale 1 ns / 1 ps

module moving_average_5_tb();

  parameter DATA_WIDTH = 16;

  reg clk;
  reg ce;
  reg signed [DATA_WIDTH-1:0] din;
  wire signed [DATA_WIDTH-1:0] dout;


  moving_average_5 #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  DUT (
    .clk(clk),
    .din(din),
    .ce(ce),
    .dout(dout)
  );

  parameter CLK_PERIOD = 8;

  initial begin
    clk = 1;
    ce=0;
    din = 0;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;



    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 10;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -10;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = -15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 15;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
    #(CLK_PERIOD*100) din = 0;
 

    $finish;
  end

  always #(CLK_PERIOD/2) clk = ~clk;
  always begin
     #(CLK_PERIOD*99) ce = 1;
     #(CLK_PERIOD) ce=0;
  end

endmodule


