
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 16,
parameter ABITS = 8


)

(
  input wire clk,
  input wire load_val,
  input wire msf_carrier_pulse,
  input wire one_sec_marker,
  input wire [12:0] number_msf_periods,
  input wire rst,
  input wire signed [NBITS-1:0] amplitude,
  output reg signed [NBITS-1:0] average,
  output reg valid,
  output reg signed [NBITS+ABITS-1:0] accumulator,
  output reg [12:0] counter

);   


//	reg signed [NBITS+ABITS-1:0] accumulator;
//	reg [12:0] counter;

   





  always @(posedge clk) begin
    if (rst==1'b1) begin
      accumulator <= 24'b000000000000000000000000;
	  counter <= 10'b0000000000;
      average <=  0;
    end
    else begin

        if (msf_carrier_pulse == 1'b1) begin
            counter <= counter + 1 ;
	     end
	     
        if (one_sec_marker==1'b1) begin
                counter <= 10'b0000000000;
                average <= accumulator[NBITS+ABITS-1:ABITS];
                valid <= 1;

	            accumulator <= 0;	            

          end

	    else if (counter == number_msf_periods) begin
	            counter <= 10'b0000000000;
                valid <= 1'b1;
                average <= accumulator[NBITS+ABITS-1:ABITS];

                accumulator <= 0;	            

           end              
         else  if (load_val==1'b1) begin
         
                 accumulator <= accumulator +   amplitude;
         
                valid <= 1'b0;        
         end
               
         else begin
             accumulator <= accumulator;
             valid <= 1'b0;                 
         end

 

         
    end
end



endmodule
 



