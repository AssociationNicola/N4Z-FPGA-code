
`timescale 1 ns / 1 ps

//The SSB frequency is the clock frequency times the ssb_freq value divided by 2**(24+3), so with a clock of 8*8.192MHz (clock has been increased to reduce jitter)
//for 87kHz ssb_freq should be 178176 (ie freqx2.048)
//Max frequency that can be generated with that clock fequency is ~128kHz
// Max amplitude is 2**25-2**20 (testing dec 2021), (?????so scale so that 2*22 is not exceeded (ie bit 23 should be zero, so that max value is in fact 2**22-1)????).
//Frequency shift is delta_phase * clock frequency/2**24, so with 8.192MHz for 1kHz shift, need deltaphase of 2048 (max value is 2^13-1, ie 8191 (about 4kHz offset)
// Now to do QPSK, set_qpsk =1 and the value of the phase on qpsk: ( 2**NBITS , 2**[NBITS+1] + 2**NBITS, 2**[NBITS+2] + 2**NBITS, 2**[NBITS+2] +2**[NBITS+1] + 2**NBITS )

module ssbiq_modulator #
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
  input set_qpsk,
  input [NBITS+2:0] qpsk_phase,
  output reg DRV0,
  output reg DRV1
);   


//
	reg [NBITS+2:0]  count, accumulator , accumulator0, amplitude0;
    reg [1:0] prev_iq;
	
//Constant amplitude for QPSK is 2**[NBITS+1]-2**[NBITS-4]
   
  always @(posedge clk) begin
    if(rst)
    begin
      accumulator0 <=26'b0;
      
    end
    else
    begin



	if (accumulator[NBITS+2]==1) begin
		count = 2**(NBITS+3)-1 - accumulator;
	end
	else begin
		count = accumulator;
	end

	if (set_qpsk==0) begin
	   amplitude0 <= amplitude;
       accumulator0 <= accumulator0 + ssb_freq + delta_phase;
	end else begin
	   amplitude0 <= 2**(NBITS+1)-2**(NBITS-4);
	   accumulator0 <= accumulator0 + ssb_freq;
    end

	  
    if (stdby==1) begin
		DRV0=0;
		DRV1=0;
	end
    else begin
//changed this for BRAM version to stop Q phase modulation when not QPSK
      if (set_qpsk==0) begin 
	  accumulator <= accumulator0;
      end else begin
	   accumulator <= accumulator0+qpsk_phase;

      end
  



      if (count < amplitude0) begin
		DRV0=0;
		DRV1=1;
		  
	  end
		else if (count > 2**(NBITS+2)-amplitude0) begin
		DRV0=1;
		DRV1=0;		  
      end
      else begin
		DRV0=1;
		DRV1=1;
	  end
	end
  end
end
endmodule
