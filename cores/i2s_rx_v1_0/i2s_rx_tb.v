`timescale 1 ns / 1 ns

module i2s_rx_tb();

	reg Reset;
	reg Clock;
	reg LRClock;
	reg SData;
	wire [31:0] Audio;
	wire [4:0] channelBitCount;
	wire IsLeft;
	wire IsUpdate;			

//	for Lattice Semiconductor devices.	
//	PUR PUR_INST();
//	GSR GSR_INST(.GSR());

	i2s_rx top(.Reset(Reset), .LRClock(LRClock), .Clock(Clock), .Data(SData), .Audio(Audio), .channelBitCount(channelBitCount), .IsLeft(IsLeft), .IsUpdate(IsUpdate));
	
	reg [9:0] i;
	reg [5:0] lastBit;
	reg [31:0] TestData;	

	reg [9:0] k;
	
	// i2s

	task outChannel(
	input reg [31:0] TestData,
	input reg [5:0] bitCount);
		begin
			lastBit = bitCount - 1;
			for (i = 0; i < bitCount - 1; i=i+1) begin
				#0 SData = TestData[bitCount - 1];
				#32 TestData = TestData << 1;
			end
			#0 LRClock = ~LRClock;
			#0 SData = TestData[lastBit];
			#32 TestData = TestData << 1;
		end
	endtask

	// leftjust
/*	task outChannel(
	input reg [31:0] TestData,
	input reg [5:0] bitCount);
		begin
			lastBit = bitCount - 1;
			for (i = 0; i < bitCount - 1; i++) begin
				#0 SData = TestData[bitCount - 1];
				#32 TestData = TestData << 1;
			end
			#0 SData = TestData[lastBit];
			#32 TestData = TestData << 1;
			LRClock = ~LRClock;
		end
	endtask
*/	

	always begin
		#0 Clock = 0;
		#16 Clock = 1;
		#16;
	end

	initial begin

		$dumpfile("a.vcd");
		$dumpvars(0, top);

		#0 	Reset = 1;
		#500 Reset = 0;
		
		#32 LRClock = 1;
		#96;
		#64 LRClock = 0;
		#64;
	
		outChannel(16'h8991, 16);		// Invalid
		outChannel(16'h0391, 16);		// Invalid
		outChannel(16'h1234, 16);		// Invalid
		outChannel(16'h8002, 16);		// Invalid
		outChannel(32'h15F07712, 32);	// Left
		outChannel(32'h16F0FF34, 32);	// Invalid
		outChannel(16'h8001, 2);		// Invalid
		outChannel(16'h8001, 2);		// Invalid
		outChannel(32'haabbc718, 32);	// Left
		outChannel(32'h12345678, 32);	// Invalid

		outChannel(16'h8001, 16);		// Left
		outChannel(16'h8301, 16);		// Right
		outChannel(32'h15F07712, 31);	// Invalid
		outChannel(32'h16F0FF34, 31);	// Invalid
		outChannel(16'h7712, 16);		// Left
		outChannel(16'hFF00, 16);		// Right
		outChannel(16'hCDEF, 16);		// Left
		outChannel(16'h7654, 16);		// Right
		outChannel(16'hC111, 16);		// Left
		outChannel(16'h8888, 16);		// Right
		outChannel(24'hABC133, 24);		// Left
		outChannel(24'hFFF00F, 24);		// Invalid

		outChannel(32'hA999, 16);		// Left (valid)
		outChannel(32'h9777, 16);		// Right (Valid)
		
		
		outChannel(16'hA991, 16);		// Left (valid)
		outChannel(16'h9707, 16);		// Right (Valid)
		outChannel(16'h3332, 16);		// Left (Valid)
		outChannel(16'h4123, 16);		// Right (Valid)
		outChannel(16'hA999, 16);		// Left (valid)
		outChannel(16'h9777, 16);		// Right (Valid)
		outChannel(16'hA991, 16);		// Left (valid)
		outChannel(16'h9707, 16);		// Right (Valid)
/*	
		for (k = 0; k < 192; k=k+1) begin
			outChannel((k << 8) | k, 16);
			outChannel((k << 8) | k + 1, 16);
		end
*/		
		#500;
	
		$finish();
	end
	
	
endmodule
