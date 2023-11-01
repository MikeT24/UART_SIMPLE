import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
module rx_shifter (
	input n_rst,
	input clk,
	input rx_shift,
	input rx,
	input [UART_FRAME_SIZE-1:0] rx_data_index,
	input [UART_FRAME_SIZE-1:0] uart_data_width,
	input rx_done,
	output rx_byte_stop rx_byte
); 


//UART_FRAME_WIDHT - 2 //Does not include the start bit
logic [UART_FRAME_WIDHT-2:0] rx_byte_buffer_nxt;
logic [UART_FRAME_WIDHT-2:0] rx_byte_buffer;
rx_byte_stop rx_byte_nxt;

logic rx_done_ff;
`MIKE_FF_NRST(rx_done_ff, rx_done, clk, n_rst)


`MIKE_FF_NRST(rx_byte_buffer, rx_byte_buffer_nxt, clk, n_rst)


//Shifter for RX
always_comb begin 
	if (rx_shift)	rx_byte_buffer_nxt = {rx_byte_buffer[UART_DATA_WIDTH+1:0],rx};
	else			rx_byte_buffer_nxt = rx_byte_buffer;
end

logic [UART_DATA_WIDTH-1:0] rx_byte_buffer_inverted;
for(genvar i=0; i<UART_DATA_WIDTH; i++) assign rx_byte_buffer_inverted[i]=rx_byte_buffer[UART_DATA_WIDTH-i-1];


for (genvar g_bit = 0; g_bit < UART_DATA_WIDTH; g_bit++) begin // Does not include start bit
	assign rx_byte_nxt.rx_byte[g_bit] = (g_bit < uart_data_width) ? rx_byte_buffer[g_bit] : 1'bz;
	//assign rx_byte_nxt.rx_byte[g_bit] = rx_byte_buffer[g_bit];
end

assign rx_byte_nxt.parity 						= rx_byte_buffer[uart_data_width];
assign rx_byte_nxt.stop 						= rx_byte_buffer[uart_data_width+1];

`MIKE_FF_EN_NRST(rx_byte, rx_byte_nxt, rx_done_ff, clk, n_rst)

endmodule 

