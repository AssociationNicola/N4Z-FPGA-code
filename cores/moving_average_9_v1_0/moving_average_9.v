`timescale 1 ns / 1 ps

module moving_average_9 #
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
  reg signed [DATA_WIDTH-1:0] din2;
  reg signed [DATA_WIDTH+1-1:0] s2;
  reg signed [DATA_WIDTH+1-1:0] s3;
  reg signed [DATA_WIDTH+1-1:0] s4;

  reg signed [DATA_WIDTH+2-1:0] ss5;
  reg signed [DATA_WIDTH+2-1:0] ss6;
  reg signed [DATA_WIDTH+2-1:0] ss7;
  reg signed [DATA_WIDTH+2-1:0] ss8;
  reg signed [DATA_WIDTH+2-1:0] ss9;
  reg signed [DATA_WIDTH+3-1:0] ss10;
  reg signed [DATA_WIDTH+3-1:0] ss11;

  always @(posedge clk) begin
    if ( ce ) begin
	    din1 <= din;
	    din2 <= din1;
	    s2 <= din1+din;
	    s3 <= s2;
	    s4 <= s3;
	    ss5 <= s4 + s2+1;
	    ss6 <= ss5;
	    ss7 <= ss6;
	    ss8 <= ss7;
	    ss9 <= ss8;
	    
	    ss10 <= ss9+ss5+1;
	    ss11 <= ss10+din2+1;
    end
  end

  assign dout = ss11[DATA_WIDTH+3-1:3];

endmodule
