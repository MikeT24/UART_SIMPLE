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

rx_byte_stop rx_byte_tmp;


logic rx_done_ff;
`MIKE_FF_NRST(rx_done_ff, rx_done, clk, n_rst)


`MIKE_FF_NRST(rx_byte_buffer, rx_byte_buffer_nxt, clk, n_rst)


//Shifter for RX
always_comb begin 
	if (rx_shift)	rx_byte_buffer_nxt = {rx_byte_buffer[UART_DATA_WIDTH+1:0],rx};
	else			rx_byte_buffer_nxt = rx_byte_buffer;
end

//logic [UART_FRAME_WIDHT-1:0] rx_byte_buffer_inverted;
//for(genvar i=0; i<UART_FRAME_WIDHT; i++) assign rx_byte_buffer_inverted[i]=rx_byte_buffer[UART_FRAME_WIDHT-i-1];

generate
	genvar g_bit;
	for (g_bit = 0; g_bit < UART_DATA_WIDTH; g_bit++) begin : gen_rx_byte	// Does not include start bit
		assign rx_byte_nxt.rx_byte[g_bit] = (g_bit < uart_data_width) ? rx_byte_buffer[g_bit] : 1'bz;
		//assign rx_byte_nxt.rx_byte[g_bit] = rx_byte_buffer[g_bit];
	end
endgenerate

assign rx_byte_nxt.parity 						= rx_byte_buffer[uart_data_width];
assign rx_byte_nxt.stop 						= rx_byte_buffer[uart_data_width+1];

`MIKE_FF_EN_NRST(rx_byte_tmp, rx_byte_nxt, rx_done_ff, clk, n_rst)

// for(genvar i=0; i<UART_FRAME_WIDHT; i++) assign rx_byte2[i]=rx_byte[UART_FRAME_WIDHT-i-1];

assign rx_byte[0] = rx_byte_tmp[9];
assign rx_byte[1] = rx_byte_tmp[8];
assign rx_byte[2] = rx_byte_tmp[7];
assign rx_byte[3] = rx_byte_tmp[6];
assign rx_byte[4] = rx_byte_tmp[5];
assign rx_byte[5] = rx_byte_tmp[4];
assign rx_byte[6] = rx_byte_tmp[3];
assign rx_byte[7] = rx_byte_tmp[2];
assign rx_byte[8] = rx_byte_tmp[1];
assign rx_byte[9] = rx_byte_tmp[0];

endmodule 

