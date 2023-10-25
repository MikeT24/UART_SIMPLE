import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
module rx_shifter (
	input n_rst,
	input clk,
	input rx_shift,
	input rx,
	output logic [UART_DATA_WIDTH-1:0] rx_byte
); 



logic [UART_DATA_WIDTH-1:0] rx_byte_nxt;

`MIKE_FF_NRST(rx_byte, rx_byte_nxt, clk, n_rst)


//Shifter for RX
always_comb begin 
	if (rx_shift) rx_byte_nxt = {rx_byte[UART_DATA_WIDTH-2:0],rx};
	else			  rx_byte_nxt = rx_byte;
end

 


endmodule 

