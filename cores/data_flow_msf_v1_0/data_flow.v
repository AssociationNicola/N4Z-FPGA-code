`timescale 1 ns / 1 ps

module data_flow #
(
parameter SHIFTBITS = 4

)

(
  input         clk,
  input wire [15:0] msf_level,
  input wire [31:0] stored_level_second,
  input wire [31:0] stored_level_minute,


  output reg  [31:0]  level_to_store_second,
  output reg  [31:0]  level_to_store_minute

);



always @(posedge clk) begin
    level_to_store_second <=  msf_level +  stored_level_second - (stored_level_second>>SHIFTBITS);
    level_to_store_minute <=  msf_level +  stored_level_minute - (stored_level_minute>>SHIFTBITS);

  end

  

endmodule
