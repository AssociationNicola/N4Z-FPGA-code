`timescale 1 ns / 1 ps

module iq_analyse #
(
  parameter integer DATA_WIDTH = 16
)
(
  input  wire clk,
  input wire  ce,
  input wire strobe_in,
  input wire rst,
  input  wire signed [DATA_WIDTH-1:0]  I_4sum,
  input  wire signed [DATA_WIDTH-1:0]  Q_4sum,
  input  wire [DATA_WIDTH-1:0]  Amp_4sum,
  output   reg [DATA_WIDTH-1:0] Max_Amp,  //Temp
  output reg [6:0] bits_count,
  output   reg  [2:0] sync_count,    //Temp 
  output   reg  [2:0] max_sync,  //Temp  
  output reg signed [DATA_WIDTH+8-1:0]  DI,     //TEMP need to only use top 16 bits
  output reg signed [DATA_WIDTH+8-1:0]  DQ,
  output wire [DATA_WIDTH-1:0] Ave_Amp_Out,  //Temp
  output reg strobe_out

);



//  reg [DATA_WIDTH-1:0] Max_Amp;
  reg [DATA_WIDTH+8-1:0] Ave_Amp[0:4];
  reg [DATA_WIDTH+8-1:0] AmpSum;

//  reg  [2:0] sync_count;
//  reg  [2:0] max_sync;
    reg signed [DATA_WIDTH+8-1:0] I_ave[0:79];
  reg signed [DATA_WIDTH+8-1:0] Q_ave[0:79];

  reg strobe1;
  reg strobe2;
  integer i;
  wire signed [DATA_WIDTH+8-1:0] I4sumExt;
  wire signed [DATA_WIDTH+8-1:0] Q4sumExt;
  assign I4sumExt= {{8{I_4sum[15]}},I_4sum};
  assign Q4sumExt= {{8{Q_4sum[15]}},Q_4sum};
  
  always @(posedge clk) begin
    if (rst) begin
      sync_count <= 3'b000;
      bits_count <= 6'b00000;
      Max_Amp <= 16'h0110;
      Ave_Amp[0]<=24'h000100;
      Ave_Amp[1]<=24'h000100;
      Ave_Amp[2]<=24'h000100;
      Ave_Amp[3]<=24'h000100;
      Ave_Amp[4]<=24'h000100;
      AmpSum<=24'h000000;

     for (i=0; i<80; i=i+1) begin
        I_ave[i]=24'sh000000; 
        Q_ave[i]=24'sh000000;
     end      
           
    end
    else begin

    strobe1 <= strobe_in;
    strobe2 <= strobe1;
    strobe_out <= strobe2;


    if ( (ce==1) & (strobe_in==1) ) begin

            if (Ave_Amp_Out>Max_Amp) begin
                Max_Amp=Ave_Amp_Out;
                max_sync <= sync_count;
            end

            else if (Max_Amp<=255 & Max_Amp>0) begin
                Max_Amp <= Max_Amp-1;
            end else begin
                Max_Amp <=Max_Amp - (Max_Amp>>8);           
            end
            Ave_Amp[sync_count] <= Ave_Amp[sync_count] + {8'h00, Amp_4sum} - ((Ave_Amp[sync_count])>>8) ;
 

	    if (sync_count==4) begin
               sync_count <= 3'b000;
         end else begin
             sync_count <= sync_count+1;
         end

         if (sync_count==0) begin
             if (bits_count==79) begin
                 bits_count <= 0;
             end else begin
                 bits_count <= bits_count+1;
             end
 
         end            

    end

    if ( (ce==1) & (strobe_out==1) ) begin
    $display("inloop");
         if (sync_count==max_sync) begin
             I_ave[bits_count] <= I_ave[bits_count] - ((I_ave[bits_count])>>>8) + I4sumExt  ;
             Q_ave[bits_count] <= Q_ave[bits_count] - ((Q_ave[bits_count])>>>8) + Q4sumExt  ;
             if (bits_count<40) begin
                 DI <= I_ave[bits_count] - I_ave[bits_count+40];
                 DQ <= Q_ave[bits_count] - Q_ave[bits_count+40];
          $display("sync_count is %d and I_ave[bits_count] is %d, I_ave[bits_count+40] is %d,  {{8{I_4sum[15]}},I_4sum} is %d, bits_count = %d",sync_count,I_ave[bits_count],I_ave[bits_count+40], {{8{I_4sum[15]}},I_4sum},bits_count);

             end
             else begin
                 DI <= I_ave[bits_count-40] - I_ave[bits_count];
                 DQ <= Q_ave[bits_count-40] - Q_ave[bits_count];
          $display("sync_count is %d and I_ave[bits_count-40] is %d, I_ave[bits_count] is %d,  {{8{I_4sum[15]}},I_4sum} is %d, bits_count = %d",sync_count,I_ave[bits_count-40],I_ave[bits_count], {{8{I_4sum[15]}},I_4sum},bits_count);

             end
            
          end


    end


  end


  end


  assign Ave_Amp_Out=Ave_Amp[sync_count][23:8];

endmodule
