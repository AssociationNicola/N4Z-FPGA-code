`timescale 1 ns / 1 ps

//This is re-written to count to 2**14 so 16384 values and not reset on the second marker (assumes time stamp will be written to contents of data)
//This is to stor more than 1s of data

module timing_control #
(

)


(
  input  wire                         cic_40_pulse,
  input  wire                         rst,
  input  wire    		      clk,		//normally $adc_clk

  output reg  [15:0]                  cic_pulse_counter  //typically wraps at 2**16 - used for IQBRAM address (top 14 bits)

);



  initial begin



  end
//should be ( msf_carrier_counter[6:0]==7'b0000000 ) - writes every 128th carrier pulse
 always @(posedge clk) begin

  if (rst) begin
      cic_pulse_counter <= 0;

  end else begin


         if (cic_40_pulse==1'b1) begin
             cic_pulse_counter <= cic_pulse_counter +1;

         end else begin

         end

  end     


end

endmodule
