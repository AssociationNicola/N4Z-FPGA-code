`timescale 1 ns / 1 ps

module timing_control #
(
parameter SECONDS_MINUTE = 59

)


(
  input  wire                         msf_carrier_pulse,
  input  wire [16:0]                  msf_frequency,
  input  wire [16:0]                  low_time,          //This is taken from the lowest stored value in second memory times 8 (add 3 LSB 0s)
  input  wire    		      clk,		//normally $adc_clk
  

  output reg  [16:0]                 msf_carrier_counter,  //For Frankfurt, counts 0-77499 (address used for the second bram)
  output reg  			      one_sec_marker,
  output reg  [5:0]                 second_counter,	//count 0-59 (address used for the minute bram)
  output wire  [3:0]                 write_second_bram,	//
  output reg  [3:0]                 write_minute_bram

);


  reg  [2:0] still_low_time  = 3'b000;
  reg  carrierpulsedelay = 1'b0;
  reg  carrierpulsedelay2 = 1'b0;
  reg  carrierpulsedelay3 = 1'b0;
//  reg start;


  initial begin
    msf_carrier_counter <= 0;
    second_counter <= 0;


  write_minute_bram <= 0;   


  end
//should be ( msf_carrier_counter[6:0]==7'b0000000 ) - writes every 128th carrier pulse
 always @(posedge clk) begin
    carrierpulsedelay <= msf_carrier_pulse & ( msf_carrier_counter[6:0]==7'b0000000 );
    carrierpulsedelay2 <= carrierpulsedelay;
    carrierpulsedelay3 <= carrierpulsedelay2;    
    if (msf_carrier_pulse) begin
       if (msf_carrier_counter < msf_frequency-1) begin

           msf_carrier_counter <= msf_carrier_counter+1;
       end
       else begin
           msf_carrier_counter<=0;
       end
    end
	if (msf_carrier_counter == low_time) begin
              one_sec_marker <= 1'b1;
              if (still_low_time==3'b000) begin
                  still_low_time <= still_low_time+1;

                  if (second_counter<SECONDS_MINUTE) begin
	                  second_counter <= second_counter+1;
                  end
                  else begin
                      second_counter <= 0;
                  end
                 
              end else if (still_low_time==3'b100 ) begin
                  write_minute_bram <= 4'b1111 ;
                  still_low_time <= still_low_time+1;
              end else if (still_low_time==3'b101 ) begin
                  still_low_time <= still_low_time;
                  write_minute_bram <= 4'b0000 ;
              end else 
                 still_low_time <= still_low_time+1;
            
	end
        else begin
            still_low_time <= 3'b000;
            write_minute_bram <= 4'b0000 ;
            one_sec_marker <= 1'b0;
        end



    
end
//Only write second_bram ever 2^7 carrier pulses (eg at 605.47Hz for Frankfurt)
assign  write_second_bram = {carrierpulsedelay3,carrierpulsedelay3,carrierpulsedelay3,carrierpulsedelay3} ;

endmodule
