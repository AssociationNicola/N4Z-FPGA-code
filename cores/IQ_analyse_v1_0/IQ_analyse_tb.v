`timescale 1 ns / 1 ps


module iq_analyse_tb();

  parameter DATA_WIDTH = 16;

  reg clk;
  reg ce;
  reg strobe_in;
  reg rst;
  reg signed [DATA_WIDTH-1:0]  I_4sum;
  reg signed [DATA_WIDTH-1:0]  Q_4sum;

  reg [DATA_WIDTH-1:0]  Amp_4sum;

  wire [6:0] bits_count;

  wire signed [DATA_WIDTH+8-1:0] DI;   //Temp wider signal!
  wire signed [DATA_WIDTH+8-1:0] DQ;


  wire strobe_out;
//Temp
  wire [DATA_WIDTH-1:0] Ave_Amp_Out;
  wire [DATA_WIDTH-1:0] Max_Amp;
  wire [2:0] sync_count;
  wire [2:0] max_sync;
    
  iq_analyse #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  DUT (
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .strobe_in(strobe_in),
    .I_4sum(I_4sum),
    .Q_4sum(Q_4sum),
    .Amp_4sum(Amp_4sum),

    .bits_count(bits_count),
    .DI(DI),
    .DQ(DQ),

    .strobe_out(strobe_out),
    .Ave_Amp_Out(Ave_Amp_Out),    //Temp
    
    .Max_Amp(Max_Amp),  //temp
    .sync_count(sync_count),  //Temp
    .max_sync(max_sync)    //Temp
    
    
  );

  parameter CLK_PERIOD = 8;

  initial begin
    clk = 1;
    ce=0;
    Amp_4sum = 0;
    rst=1;
    strobe_in = 0;
    I_4sum = 0;
    Q_4sum = 0;
    #(CLK_PERIOD*100) rst=0; ce=1;

    #(CLK_PERIOD*1000000) ce=0;

 

    $finish;
  end

  always #(CLK_PERIOD/2) clk = ~clk;


  always begin
     #(CLK_PERIOD*9) strobe_in = 1;
     #(CLK_PERIOD) strobe_in=0;
  end

  always begin


     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*10) Amp_4sum = 49; I_4sum = 29; Q_4sum = 40;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;


     repeat(7)  begin
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     end


     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*10) Amp_4sum = 49; I_4sum = -29; Q_4sum = -40;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;


     repeat(7)  begin
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = -40; Q_4sum = 30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = 7; Q_4sum = -8;

     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*10) Amp_4sum = 50; I_4sum = 40; Q_4sum = -30;
     #(CLK_PERIOD*10) Amp_4sum = 30; I_4sum = 25; Q_4sum = -20;
     #(CLK_PERIOD*10) Amp_4sum = 10; I_4sum = -8; Q_4sum = -7;

     end



  end

endmodule


