
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 16,
parameter ABITS = 8

)
(
  input clk,
  input next,
  input rst,
  input [NBITS-1:0] amplitude,
  output  [NBITS-1:0] average,
  output reg [NBITS-1:0] max_val
);   

	reg [NBITS+ABITS-1:0] accumulator;
   
	assign average = accumulator[NBITS+ABITS-1:ABITS];

  always @(posedge clk) begin
    if (rst) begin
      accumulator <= 1'b0;
	  max_val <= 4'b101;
	end
	else begin
        if (next==1) begin
           accumulator <= accumulator + amplitude - (accumulator>>ABITS);
        
            if (amplitude > max_val)
                max_val <= amplitude;
        
            
            else
               max_val <= max_val - (max_val>>ABITS);
               
         end else begin
             max_val <= max_val;
             accumulator<=accumulator;
         end
     end
            
	  
  end

endmodule
