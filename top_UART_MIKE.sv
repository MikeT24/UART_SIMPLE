import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		
module top_UART_MIKE (
input test);


logic	clk;
logic	n_rst;
logic	[UART_DATA_WIDTH-1:0] tx_data;
logic	tx_send;
logic	rx;
logic	tx;
logic	parity_error;
logic	rx_flag;
logic	[UART_DATA_WIDTH-1:0] rx_data;
logic rx_flag_clr;

UART_MIKE dut_UART_MIKE(
	.clk	(clk),
	.n_rst	(n_rst),
	.tx_data	(tx_data),
	.tx_send	(tx_send),
	.rx	(rx),
	.tx	(tx),
	.parity_error	(parity_error),
	.rx_flag	(rx_flag),
	.rx_data	(rx_data),
	.rx_flag_clr(rx_flag_clr)
);



  initial begin
    n_rst = 0;
    clk = 0;
	 tx_data = 8'b01010101;
	 tx_send = '0;
	 rx = '1;
	 
	 
   #20;
    n_rst = 1;
	#100;
		rx = '0;
	#50;
		rx = '1;
	#100
		rx = '1;
		
	#1400
		rx_flag_clr = 1'b1;
	#60
		rx_flag_clr = 1'b0;
	#20
		tx_send = 1'b1;
	#20 
		tx_send = 1'b0;

	 
  end

  
  initial begin 
    forever #5 clk = ~clk;
  end

endmodule
