
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 32,
parameter ABITS = 8,
parameter STOPAT = 320

)
(
  input clk,
  input load_val,
  input rst,
  input [NBITS-1:0] amplitude,
  output  [NBITS-1:0] average,
  output valid

);   

	reg [NBITS+ABITS-1:0] accumulator;
	reg [8:0] counter;

   
	assign average = accumulator[NBITS+ABITS-1:ABITS];
	assign valid = (counter == STOPAT) && (load_val ==1);

  always @(posedge clk) begin
    if (rst) begin
      accumulator <= 0;
	  counter <= 9'b000000000;

	end
	else begin
        if (load_val==1) begin

	   if (counter == STOPAT) begin
	      counter <= 9'b000000000;
	      accumulator <= 0;

	   end
           else begin

              accumulator <= accumulator + amplitude;
	      counter <= counter + 1;
           end
            
         end else begin
             accumulator<=accumulator;
         end
     end
            
	  
  end

endmodule
