`timescale 1 ns / 1 ps

module moving_average_5 #
(
  parameter integer DATA_WIDTH = 16
)
(
  input  wire clk,
  input wire  ce,
  input  wire signed [DATA_WIDTH-1:0]  din,
  output wire signed [DATA_WIDTH-1:0]  dout
);

  reg signed [DATA_WIDTH-1:0] din1;
  reg signed [DATA_WIDTH+1-1:0] s2;
  reg signed [DATA_WIDTH+1-1:0] s3;
  reg signed [DATA_WIDTH+1-1:0] s4;

  reg signed [DATA_WIDTH+2-1:0] ss5;
  reg signed [DATA_WIDTH+2-1:0] ss6;


  always @(posedge clk) begin
    if ( ce ) begin
	    din1 <= din;
	    s2 <= din1+din;
	    s3 <= s2;
	    s4 <= s3;
	    ss5 <= s4 + s2+1;
	    ss6 <= ss5+din1+1;

    end
  end

  assign dout = ss6[DATA_WIDTH+2-1:2];

endmodule
