
`timescale 1 ns / 1 ps

//The SSB frequency is the clock frequency times the ssb_freq value divided by 2**(24+3), so with a clock of 8*8.192MHz (clock has been increased to reduce jitter)
//for 87kHz ssb_freq should be 178176 (ie freqx2.048)
//Max frequency that can be generated with that clock fequency is ~128kHz
// Max amplitude is 2**22, so scale so that 2*22 is not exceeded (ie bit 23 should be zero, so that max value is in fact 2**22-1).
//Frequency shift is delta_phase * clock frequency/2**24, so with 8.192MHz for 1kHz shift, need deltaphase of 2048 (max value is 2^13-1, ie 8191 (about 4kHz offset)

module ssb_modulator #
(
  parameter NBITS = 24
)
(
  input clk,
  input rst,
  input [NBITS-11:0] delta_phase,
  input [NBITS-7:0] ssb_freq,
	input [NBITS+2:0] amplitude,
  input stdby,
  output reg DRV0,
  output reg DRV1
);   

	reg [NBITS+2:0] count, accumulator;
   
  always @(*) begin
	  if (accumulator[NBITS+2]==1) begin
		count = 2**(NBITS+3)-1 - accumulator;
	end
	else begin
		count = accumulator;
	end
	  
    if (stdby==1) begin
		DRV0=0;
		DRV1=0;
	end
    else begin
      if (count < amplitude) begin
		DRV0=0;
		DRV1=1;
		  
	  end
		else if (count > 2**(NBITS+2)-amplitude) begin
		DRV0=1;
		DRV1=0;		  
      end
      else begin
		DRV0=1;
		DRV1=1;
	  end
	end
  end

  always @(posedge clk) begin
    if (rst) begin
      accumulator <= 1'b0;
    end else begin
      accumulator <= accumulator + ssb_freq + delta_phase;
    end
  end

endmodule
