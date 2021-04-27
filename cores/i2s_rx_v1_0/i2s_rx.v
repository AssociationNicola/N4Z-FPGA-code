`timescale 1ns/1ns
`default_nettype none

module i2s_rx(
	input wire Clock,
	input wire Reset,
	input wire LRClock,
	input wire Data,
	output wire IsLeft,
	output wire IsUpdate,
	output reg [31:0] Audio,
    output reg [4:0] channelBitCount );

	
	reg [31:0] audioData;
	reg isLeftChannelState;
	reg [1:0] channelHistory;
	reg [2:0] audioShiftFlag;
	
	assign IsLeft = !isLeftChannelState;
	assign IsUpdate = audioShiftFlag[0];
	
	wire isCurrentChannelLeft = LRClock == 1'b0;
	wire isChannelChanged  = (channelHistory[0] != channelHistory[1]);

	always @(posedge Clock or posedge Reset) begin
		if (Reset) begin
			isLeftChannelState <= 0;
			channelBitCount <= 0;
			channelHistory <= 2'b00;
			audioShiftFlag <= 3'b000;
			audioData <= 0;
		end else begin
			audioData <= { audioData[30:0], Data  };
			channelHistory <= { channelHistory[0], isCurrentChannelLeft };
			if (isChannelChanged) begin
				channelBitCount <= 0;
				if (isLeftChannelState == channelHistory[1])
				begin
					case (channelBitCount)
						5'b11111: begin	// 32bit
							audioShiftFlag <= 3'b001;
							isLeftChannelState <= !isLeftChannelState;
							Audio <= audioData;
						end
						5'b10111: begin	// 24bit
							audioShiftFlag <= 3'b010;
							isLeftChannelState <= !isLeftChannelState;
							Audio <= audioData;
						end
						5'b01111: begin	// 16bit
							audioShiftFlag <= 3'b100;
							isLeftChannelState <= !isLeftChannelState;
							Audio <= audioData;
						end
						default:
							isLeftChannelState <= 1;
					endcase
				end
			end
			else
			begin
				channelBitCount <= channelBitCount + 1;
				if (audioShiftFlag[2:1] != 2'b00) begin
					Audio <= Audio << 8;
				end
				audioShiftFlag <= audioShiftFlag >> 1;
			end
		end
	end	
endmodule