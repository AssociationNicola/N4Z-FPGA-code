
`timescale 1 ns / 1 ps

module amp_limiter #
(
parameter NBITS = 16


)
(
  input clk,
  input valid,
  input rst,
  input [NBITS-1:0] amplitude,
  output reg  [NBITS-1:0] limited_amp

);   

   

 always @(posedge clk) begin
    if (rst) begin
      limited_amp <= 16'h0000;

	end
	else begin
        if (valid==1) begin
                   
            if (amplitude[15:9] == 0) begin
                limited_amp <= 16'h0000;
        
            end
            else if ((amplitude[13:9] != 0) && (amplitude[15:14] == 0) ) begin
               limited_amp <= 16'h1434 + (amplitude>>3);
            end

            else if (amplitude[15:14] != 0) begin
               limited_amp <= 16'h1a34 + (amplitude>>5);
            end
			
         end
       else begin
             limited_amp <= limited_amp;
       end
    end
            
	  
  end

endmodule
