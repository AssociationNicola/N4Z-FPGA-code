`timescale 1 ns / 1 ps

module timing_control #
(

)


(
  input  wire                         cic_40_pulse,
  input  wire                         rst,
  input  wire                         one_sec_pulse,          //From one_sec_marker
  input  wire    		      clk,		//normally $adc_clk

  output reg  [15:0]                  cic_pulse_counter,  //typically counts to ~40000 in about 1s and resets to zero on one_sec pulse - used for IQBRAM address
  output reg                          write        //pulse output for use with BRAM (expand to 4 bits and & with not TX_HIGH)

);

     reg was_one_sec;

  initial begin

    was_one_sec <= 1'b0;
 


  end
//should be ( msf_carrier_counter[6:0]==7'b0000000 ) - writes every 128th carrier pulse
 always @(posedge clk) begin
  if (rst) begin
      cic_pulse_counter <= 0;
      write<=0;
  end else begin

     if ((one_sec_pulse==1'b1) & (one_sec_pulse!=was_one_sec)) begin
         cic_pulse_counter <=0;
     end else begin
         if (cic_40_pulse==1'b1) begin
             cic_pulse_counter <= cic_pulse_counter +1;
             write <=1;
         end else begin
             write <= 0;
         end

     end

  end     


end

endmodule
