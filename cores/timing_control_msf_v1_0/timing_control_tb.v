`timescale 1 ns / 1 ps

module timing_control_tb();


  reg			msf_carrier_pulse;
  reg [8:0]		msf_frequency;
  reg [7:0]		low_time;

  reg			clk;
  reg			rst;


   wire [11:0]                 address_counter;   //This counts 0-3999 (in 16 seconds)
   wire  [8:0] msf_carrier_counter;
   wire  [7:0] second_250_counter;
   wire 		one_sec_marker;
   wire [3:0]		write_second_bram;





  timing_control #() 
  DUT (
    .msf_carrier_pulse(msf_carrier_pulse),
    .msf_frequency(msf_frequency),
    .low_time(low_time),
    .clk(clk),
    .rst(rst),
  

    .address_counter(address_counter),
    .msf_carrier_counter(msf_carrier_counter),
    .second_250_counter(second_250_counter),
    .one_sec_marker(one_sec_marker),
    .write_second_bram(write_second_bram)




  );

  parameter CLK_PERIOD = 80;

  initial begin
    clk = 1;
    msf_frequency=310;
    low_time=203;
    rst=0;
   


    #(50000*64*CLK_PERIOD)
    $finish;
  end

always begin
  #(164*CLK_PERIOD)
  msf_carrier_pulse=1;
  #(CLK_PERIOD)
  msf_carrier_pulse=0;

  end
  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule


