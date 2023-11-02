import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
module tx_shifter (
	input logic n_rst,
	input logic clk,
	input logic tx_shift,
    input logic [UART_FRAME_SIZE-1:0] tx_index,
	input tx_byte_stop tx_byte,
	input logic [UART_FRAME_SIZE-1:0] uart_data_width,
    output logic  tx
); 

logic [UART_FRAME_SIZE-1:0] temp_index;
logic [UART_FRAME_SIZE-1:0] temp_index_ff;
logic [UART_FRAME_SIZE-1:0] tx_index_ff;


assign temp_index = (temp_index_ff < UART_FRAME_WIDHT-1) ? tx_index + uart_data_width -'h8 : UART_FRAME_WIDHT-1;
// assign temp_index = tx_index + uart_data_width -'h8;
`MIKE_FF_NRST(temp_index_ff, temp_index, clk, n_rst)
`MIKE_FF_NRST(tx_index_ff, tx_index, clk, n_rst)

//REMEMBER THAT THE INDEX FROM TX_COUNTER NEEDS TO BE SUBSTRACTED - 1 
//Shifter for RX
always_comb begin : block1
	if 	(tx_index_ff >= 'h0 & tx_index_ff < uart_data_width + 1)	
		tx = tx_byte[tx_index_ff];
	else											//Getting through the array														
		tx = tx_byte[temp_index_ff]; 
end


endmodule 
