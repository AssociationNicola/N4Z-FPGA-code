`timescale 1 ns / 1 ps

module timing_control #
(

)


(
  input  wire                         msf_carrier_pulse,
  input  wire [12:0]                  msf_cp_per_bit,		//For text this would be 3100 for Frankfurt and 2400 for Rugby and fifo would repeat pairs of values to send qpsk phases at 12.5Hz
  input  wire                         one_sec_pulse,          //From one_sec_marker
  input  wire    		      clk,		//normally $adc_clk
  input wire                          qpsk_start,       //from control_val[6] to say fifo has been loaded and ready to go.
  

  output reg  [12:0]                  msf_carrier_counter,  //For Frankfurt, counts 0-77499 (address used for the second bram)
  output reg qpsk_go,
  output reg  			      next_output        //to tready through clock convertor to get next TX value

);

//     reg qpsk_go;

  initial begin
    msf_carrier_counter <= 13'b0000000000000;
    qpsk_go <= 1'b0;
    next_output <= 1'b0;   


  end
//should be ( msf_carrier_counter[6:0]==7'b0000000 ) - writes every 128th carrier pulse
 always @(posedge clk) begin
   if ( qpsk_start == 1'b1 ) begin
       
    if (msf_carrier_pulse) begin
       if (one_sec_pulse == 1'b1) begin
            next_output <= 1'b1;
            msf_carrier_counter <= 13'b0000000000000;
            qpsk_go <= 1'b1;
       end
       else begin
           if ((msf_carrier_counter==msf_cp_per_bit-1) & (qpsk_go == 1)) begin
                next_output <= 1'b1;
                msf_carrier_counter <= 13'b0000000000000;
      
           end
           else begin
                msf_carrier_counter <= msf_carrier_counter +1;
                next_output <= 1'b0;
           end
       end

   end
   else begin
            next_output <= 1'b0;
            msf_carrier_counter <= msf_carrier_counter;
   end

  end
  else begin
    qpsk_go <= 1'b0;
    next_output <= 1'b0;
  end
    
end

endmodule
