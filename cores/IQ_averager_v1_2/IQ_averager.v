
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 16,
parameter ABITS = 2


)


//ABITS shouldn't be more than 4

(
  input wire clk,
  input wire rst,

  input wire cic_40_pulse,

  input wire signed [NBITS-1:0] amplitude,
  output reg signed [NBITS-1:0] average,
  output reg valid,
  output reg signed [NBITS+ABITS-1:0] accumulator

);   


//	reg signed [NBITS+ABITS-1:0] accumulator;
	reg [4:0] counter;
	reg val;

   





  always @(posedge clk) begin
    if (rst==1'b1) begin
      accumulator <= 18'b000000000000000000;
	  counter <= 0;
      average <=  0;
    end
    else begin
       valid<=val;

        if (cic_40_pulse == 1'b1) begin
            counter <= counter + 1 ;


	     
           if (counter[ABITS-1:0]==0) begin
                accumulator <= { {ABITS {amplitude[NBITS-1]}} , amplitude}; 
         
                val <= 1;
                average <= accumulator[NBITS+ABITS-1:ABITS];

            

           end else begin
                accumulator <= accumulator +   amplitude +1;
                val <= 0;

           end

        end else begin
           val <= 0;
        end


         
    end
end



endmodule
 



