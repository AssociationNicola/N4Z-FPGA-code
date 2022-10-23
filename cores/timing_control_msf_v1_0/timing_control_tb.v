`timescale 1 ns / 1 ps

module timing_control_tb();


  reg			msf_carrier_pulse;
  reg [16:0]		msf_frequency;
  reg [16:0]		low_time;

  reg			clk;


   wire [16:0]		msf_carrier_counter;
   wire 		one_sec_marker;
   wire [5:0]		second_counter;
   wire [3:0]		write_second_bram;
   wire [3:0]		write_minute_bram;




  timing_control #() 
  DUT (
    .msf_carrier_pulse(msf_carrier_pulse),
    .msf_frequency(msf_frequency),
    .low_time(low_time),
    .clk(clk),
  

    .msf_carrier_counter(msf_carrier_counter),
    .one_sec_marker(one_sec_marker),
    .second_counter(second_counter),
    .write_second_bram(write_second_bram),
    .write_minute_bram(write_minute_bram)




  );

  parameter CLK_PERIOD = 80;

  initial begin
    clk = 1;
    msf_frequency=77500;
    low_time=303;
   


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


