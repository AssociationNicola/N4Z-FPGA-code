
`timescale 1 ns / 1 ps

module averager #
(
parameter NBITS = 16,
parameter ABITS = 8,
parameter AMBITS = 8,
parameter SKIPBITS = 5

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
        reg [SKIPBITS-1:0] skipcounter;
   
	assign average = accumulator[NBITS+ABITS-1:ABITS];

  always @(posedge clk) begin
    if (rst) begin
      accumulator <= 0;
	  max_val <= 4'b101;
          skipcounter <= 0;
	end
	else begin

        if (next==1) begin
           skipcounter <= skipcounter +1'b1;
           accumulator <= accumulator + amplitude - (accumulator>>ABITS);
        
            if (amplitude > max_val)
                max_val <= amplitude;
        
            
            else
               if (skipcounter==0)
                   max_val <= max_val - (max_val>>AMBITS);
               else
                   max_val <= max_val;
               
         end else begin
             max_val <= max_val;
             accumulator<=accumulator;
         end
     end
            
	  
  end

endmodule
