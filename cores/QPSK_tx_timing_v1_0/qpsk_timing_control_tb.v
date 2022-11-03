`timescale 1 ns / 1 ps


module timing_control_tb();


  reg			msf_carrier_pulse;
  reg [12:0]		msf_cp_per_bit;
  reg    		one_sec_pulse;

  reg			clk;
  reg                   qpsk_start;

   wire [12:0]		msf_carrier_counter;
   wire 		next_output;
   wire qpsk_go;




  timing_control #() 
  DUT (
    .msf_carrier_pulse(msf_carrier_pulse),
    .msf_cp_per_bit(msf_cp_per_bit),
    .one_sec_pulse(one_sec_pulse),
    .clk(clk),
    .qpsk_start(qpsk_start),
    .msf_carrier_counter(msf_carrier_counter),
    .qpsk_go(qpsk_go),
    .next_output(next_output)



  );

  parameter CLK_PERIOD = 80;

  initial begin
    clk = 1;
    msf_cp_per_bit=20;
    one_sec_pulse=0;
    qpsk_start=0;
    #((26500)*CLK_PERIOD)
    qpsk_start=1;
    #((506500)*CLK_PERIOD)
    qpsk_start=0;

    #(10000*64*CLK_PERIOD);
    $finish;
  end

always begin
  #(164*CLK_PERIOD)
  msf_carrier_pulse=1;
  #(CLK_PERIOD)
  msf_carrier_pulse=0;

  end
  
always begin
  #((16500-165)*CLK_PERIOD)
  one_sec_pulse=1;
  #(165*CLK_PERIOD)
  one_sec_pulse=0;

  end
  
  always #(CLK_PERIOD/2) clk = ~clk;

endmodule


