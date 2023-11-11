`timescale 1 ns / 1 ps


module iq_4sum_tb();

  parameter DATA_WIDTH = 16;

  reg clk;
  reg ce;
  reg strobe_in;
  reg signed [DATA_WIDTH-1:0] I_in;
  reg signed [DATA_WIDTH-1:0] Q_in;
  wire signed [DATA_WIDTH-1:0] I4sum;
  wire signed [DATA_WIDTH-1:0] Q4sum;
  wire strobe_out;


  iq_4sum #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  DUT (
    .clk(clk),
    .ce(ce),
    .strobe_in(strobe_in),
    .I_in(I_in),
    .Q_in(Q_in),
    .I4sum(I4sum),
    .Q4sum(Q4sum),
    .strobe_out(strobe_out)
  );

  parameter CLK_PERIOD = 8;

  initial begin
    clk = 1;
    ce=0;
    strobe_in = 0;
    I_in = 0;
    Q_in = 0;
    #(CLK_PERIOD*100) I_in = 15;
    #(CLK_PERIOD*100) Q_in = 15;
    ce=1;
    #(CLK_PERIOD*100) I_in = 15;
    #(CLK_PERIOD*100) Q_in = 15;
    #(CLK_PERIOD*100) I_in = 15;
    #(CLK_PERIOD*100) Q_in = 15;
    #(CLK_PERIOD*100) I_in = 15;
    #(CLK_PERIOD*100) Q_in = 15;
    #(CLK_PERIOD*100) I_in = 0;
    #(CLK_PERIOD*100) Q_in = 0;
    #(CLK_PERIOD*100) I_in = 0;
    #(CLK_PERIOD*100) Q_in = 0;



    #(CLK_PERIOD*10) I_in = 17;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = -17;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 17;  
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = -17; 
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = 17;  
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = -17; 
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = 17;  
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = -17; 
    #(CLK_PERIOD*10) I_in = 0;   
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
    #(CLK_PERIOD*10) I_in = 0;
     #(CLK_PERIOD*1000) I_in = 10;
 

    $finish;
  end

  always #(CLK_PERIOD/2) clk = ~clk;
  always begin
     #(CLK_PERIOD*9) strobe_in = 1;
     #(CLK_PERIOD) strobe_in=0;
  end

endmodule


