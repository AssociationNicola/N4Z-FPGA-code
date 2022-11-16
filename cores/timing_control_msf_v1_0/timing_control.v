`timescale 1 ns / 1 ps

module timing_control #
(
parameter SECONDS_MINUTE = 59

)


(
  input  wire                         msf_carrier_pulse,
  input  wire [8:0]                  msf_frequency,     // Now this is actually msf_frequency/250 ie 310 or 240
  input  wire [7:0]                  low_time,          //This is taken from the lowest stored value in BRAM (second) memory (0-249)
  input  wire    		      clk,		//normally $adc_clk
  input wire                          rst,              // sets counter to zero
  

  output reg  [11:0]                 address_counter,   //This counts 0-3999 (in 16 seconds)
  output reg  			      one_sec_marker,
  output wire  [3:0]                 write_second_bram,
  output reg   [8:0] msf_carrier_counter ,
  output reg   [7:0] second_250_counter                  	//

);


  reg  [2:0] still_low_time  = 3'b000;
  reg  write_bram = 1'b0;
//  reg  [8:0] msf_carrier_counter = 9'b000000000;      //For Frankfurt, counts 0-310 (address used for the second bram)
//  reg  [7:0] second_250_counter =8'h00;               //This counts up each time msf carrier counter resets  (at 310 or 240 as well as address counter) and resets at 249 - ie at 250Hz
//  reg start;


  initial begin
    msf_carrier_counter <= 0;
    address_counter <= 0;


  second_250_counter <= 0;   


  end
//should be ( msf_carrier_counter[6:0]==7'b0000000 ) - writes every 128th carrier pulse
 always @(posedge clk) begin
  if (rst) begin
      address_counter <= 0;
      msf_carrier_counter <= 0;
      second_250_counter <= 0;
  end else begin
    if (msf_carrier_pulse) begin
       if (msf_carrier_counter < msf_frequency-1) begin
           write_bram<=1'b0;
           msf_carrier_counter <= msf_carrier_counter+1;
       end
       else begin
           msf_carrier_counter<=0;
           write_bram <=1'b1;
           if (address_counter < 3999) begin
               address_counter <= address_counter+1;
           end else begin
              address_counter <= 0;
              second_250_counter <= 0;
           end
           if (second_250_counter < 249) begin
               second_250_counter <= second_250_counter+1; 
           end else begin
               second_250_counter <= 0;
           end          
       end
    end

    if (second_250_counter == low_time) begin
            one_sec_marker <= 1'b1;
    end else begin
            one_sec_marker <= 1'b0;
    end


  end
    
end
//Only write second_bram ever 2^7 carrier pulses (eg at 605.47Hz for Frankfurt)
assign  write_second_bram = {write_bram,write_bram,write_bram,write_bram} ;

endmodule
