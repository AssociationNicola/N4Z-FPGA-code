`timescale 1 ns / 1 ps

module iq_4sum #
(
  parameter integer DATA_WIDTH = 16
)
(
  input  wire clk,
  input wire  ce,
  input wire strobe_in,
  input  wire signed [DATA_WIDTH-1:0]  I_in,
  input  wire signed [DATA_WIDTH-1:0]  Q_in,
  output wire signed [DATA_WIDTH-1:0]  I4sum,
  output wire signed [DATA_WIDTH-1:0]  Q4sum,
  output reg strobe_out

);



  reg signed [DATA_WIDTH-1:0] Iin1;
  reg signed [DATA_WIDTH+1-1:0] Iss1;
  reg signed [DATA_WIDTH+1-1:0] Idss1;
  reg signed [DATA_WIDTH+1-1:0] Iddss1;
  reg signed [DATA_WIDTH+2-1:0] Idout;

  reg signed [DATA_WIDTH-1:0] Qin1;
  reg signed [DATA_WIDTH+1-1:0] Qss1;
  reg signed [DATA_WIDTH+1-1:0] Qdss1;
  reg signed [DATA_WIDTH+1-1:0] Qddss1;
  reg signed [DATA_WIDTH+2-1:0] Qdout;

  reg strobe1;
  reg strobe2;



  always @(posedge clk) begin
    strobe1 <= strobe_in;
    strobe2 <= strobe1;
    strobe_out <= strobe2;


    if ( ce & (strobe_in==1) ) begin
	    Iin1 <= I_in;
	    Iss1 <= I_in + Iin1+1;
	    Idss1 <= Iss1;
	    Iddss1 <= Idss1;
	    Idout <= Iddss1+Iss1+1;

	    Qin1 <= Q_in;
	    Qss1 <= Q_in + Qin1+1;
	    Qdss1 <= Qss1;
	    Qddss1 <= Qdss1;
	    Qdout <= Qddss1+Qss1+1;



    end
  end

  assign I4sum = Idout[DATA_WIDTH+2-1:2];
  assign Q4sum = Qdout[DATA_WIDTH+2-1:2];

endmodule
