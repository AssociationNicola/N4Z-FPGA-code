`timescale 1 ns / 1 ps

module data_flow_tb();


  reg	[15:0] msf_level;
  reg [31:0] stored_level_second;
  reg [31:0] stored_level_minute;
  reg			clk;


   wire [31:0]  level_to_store_second;
   wire [31:0]  level_to_store_minute;


  data_flow #() 
  DUT (
    .msf_level(msf_level),
    .stored_level_second(stored_level_second),
    .stored_level_minute(stored_level_minute),
    .clk(clk),
  
    .level_to_store_second(level_to_store_second),
    .level_to_store_minute(level_to_store_minute)

  );

  parameter CLK_PERIOD = 8;

  initial begin
    clk = 1;
    msf_level=16'h0008;
    stored_level_second=32'h00000101;
    stored_level_minute=32'h00100101;

    #(20*CLK_PERIOD)     msf_level=16'h0009;
    #(20*CLK_PERIOD)     msf_level=16'h000A;
     #(20*CLK_PERIOD) stored_level_second=32'h00000111;
    #(20*CLK_PERIOD) stored_level_minute=32'h01100101;

    #(45*CLK_PERIOD) 
    $finish;
  end
  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule


