
`timescale 1 ns / 1 ps

module photodiode_delay #
(
parameter NBITS = 24,
parameter ABITS = 12

)
(
  input clk,
  input [4:0] PD,
  input rst,

  output reg [11:0] PD0_delay, 
  output reg [31:0] PD_delays,
  output reg button_activate
);   

	reg [NBITS-1:0] accumulator0,accumulator1,accumulator2,accumulator3,accumulator4;
	    reg [NBITS-1:0] counter;
        reg [4:0] PD_Now;
        reg [4:0] PD_Was;
   
  always @(posedge clk) begin
    if (rst) begin
      counter <= 24'b0;
      accumulator0 <= 24'b0;
      accumulator1 <= 24'b0;
      accumulator2 <= 24'b0;
      accumulator3 <= 24'b0;
      accumulator4 <= 24'b0;

	end
	else begin
        counter <= counter+1;
        PD_Now <= PD;
        PD_Was <= PD_Now;

        if (counter[12:11]==3) begin
           button_activate<=0;
         end else begin
             button_activate<=1;
         end
         if (PD_Was[0]!=PD_Now[0]) begin
             if (PD_Now[0]==1) begin
                 accumulator0 <= accumulator0 + counter[13:4];
             end             

         end

         if (PD_Was[1]!=PD_Now[1]) begin
             if (PD_Now[1]==1) begin
                 accumulator1 <= accumulator1 + counter[13:4];
             end             

         end

         if (PD_Was[2]!=PD_Now[2]) begin
             if (PD_Now[2]==1) begin
                 accumulator2 <= accumulator2 + counter[13:4];
             end             

         end

         if (PD_Was[3]!=PD_Now[3]) begin
             if (PD_Now[3]==1) begin
                 accumulator3 <= accumulator3 + counter[13:4];
             end             

         end

         if (PD_Was[4]!=PD_Now[4]) begin
             if (PD_Now[4]==1) begin
                 accumulator4 <= accumulator4 + counter[13:4];
             end             

         end

         if (counter==0) begin
             PD_delays <= {accumulator3[20:13],accumulator2[20:13],accumulator1[20:13],accumulator0[20:13]};
             PD0_delay <= accumulator0;
             accumulator0 <= 24'b0;
             accumulator1 <= 24'b0;
             accumulator2 <= 24'b0;
             accumulator3 <= 24'b0;
             accumulator4 <= 24'b0;             

         end



     end
            
	  
  end

endmodule
