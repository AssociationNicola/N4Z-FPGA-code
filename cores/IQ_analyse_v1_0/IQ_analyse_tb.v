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

  wire signed [DATA_WIDTH-1:0] DI_out;  
  wire signed [DATA_WIDTH-1:0] DQ_out;

  wire max_val_sync;
  wire strobe_out;

    
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
    .max_val_sync(max_val_sync),
    .bits_count(bits_count),
    .DI_out(DI_out),
    .DQ_out(DQ_out),

    .strobe_out(strobe_out)


    
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

    #(CLK_PERIOD*10000000) ce=0;

 

    $finish;
  end

  always #(CLK_PERIOD/2) clk = ~clk;


  always begin
     #(CLK_PERIOD*30) strobe_in = 1;
     #(CLK_PERIOD) strobe_in=0;
     #(CLK_PERIOD*19) strobe_in=0;     
  end

  always begin


     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 29; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 49;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     



     repeat(7)  begin
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     end

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -29; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 49;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     



     repeat(7)  begin
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -7; Q_4sum = -8;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = 20; Q_4sum = -25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = -30; Q_4sum = -40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = -25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     #(CLK_PERIOD*30)  I_4sum = -8; Q_4sum = 7;
     #(CLK_PERIOD*20) Amp_4sum = 10;
     #(CLK_PERIOD*30) I_4sum = -20; Q_4sum = 25;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30) I_4sum = 30; Q_4sum = 40;
     #(CLK_PERIOD*20) Amp_4sum = 50;     
     #(CLK_PERIOD*30) I_4sum = 25; Q_4sum = 20;
     #(CLK_PERIOD*20) Amp_4sum = 30;     
     #(CLK_PERIOD*30)  I_4sum = 8; Q_4sum = -7;
     #(CLK_PERIOD*20) Amp_4sum = 10;     

     end




  end

endmodule


