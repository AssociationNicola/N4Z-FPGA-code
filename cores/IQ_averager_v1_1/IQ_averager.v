
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 16,
parameter ABITS = 8


)

(
  input clk,
  input load_val,
  input msf_carrier_pulse,
  input one_sec_marker,
  input [12:0] number_msf_periods,
  input rst,
  input signed [NBITS-1:0] amplitude,
  output reg signed [NBITS-1:0] average,
  output reg valid

);   

	reg signed [NBITS+ABITS-1:0] accumulator;
	reg [12:0] counter;


   





  always @(posedge clk) begin
    if (rst) begin
      accumulator <= 0;
	  counter <= 10'b0000000000;
      average <=  0;
    end
    else begin

        if (msf_carrier_pulse == 1) begin
            counter <= counter +1;

            if (one_sec_marker == 1'b1) begin
                counter <= 10'b0000000000;
                average <= accumulator[NBITS+ABITS-1:ABITS];
                valid <= 1;
                if (load_val==1) begin
	                accumulator <= amplitude;
	            end else begin
	                accumulator <= 0;	            
	            end
            end
        end
	    else if (counter == number_msf_periods) begin
	            counter <= 10'b0000000000;
                valid <= 1;
                average <= accumulator[NBITS+ABITS-1:ABITS];
                if (load_val==1) begin
	                 accumulator <= amplitude;
	            end else begin
	                 accumulator <= 0;	            
	            end
         end

        else begin
                valid <= 0;
                if (load_val==1) begin
                   accumulator <= accumulator + amplitude;
                end
 
               
            end
	   end



            

   end
            
	  


endmodule
