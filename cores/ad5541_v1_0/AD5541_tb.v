`timescale 1 ns / 1 ps

module ad5541_tb();

  reg                     rstn;
  reg [15:0]            data;
  reg                     clk;
  reg                    valid;
  wire [2:0]    export_state;
  wire [6:0]    count_next;

  ad5541 #()
  DUT (
    .rstn(rstn),
    .data(data),
    .clk(clk),
    .valid(valid),
    .cs(cs),
    .ldac(ldac),
    .sclk(sclk),
    .din(din),
    .export_state(export_state),
    .count_next(count_next)
    
  );

  parameter CLK_PERIOD = 8;



  initial begin
    clk = 1;
    data = 79;
    rstn = 1;  
    valid=0;  
    #(10*CLK_PERIOD) rstn = 0;
    #(1*CLK_PERIOD) rstn = 1;
    valid=1;
    #(CLK_PERIOD) valid=0;
    #(48*CLK_PERIOD) valid=1;
    #(CLK_PERIOD) valid=0;
        
    #(48*CLK_PERIOD) valid=1;
    #(CLK_PERIOD) valid=0;
    
    #(48*CLK_PERIOD) valid=1;
    #(CLK_PERIOD) valid=0;

    #(48*CLK_PERIOD) valid=1;

    #(100*CLK_PERIOD)
    $finish;
  end
  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule

