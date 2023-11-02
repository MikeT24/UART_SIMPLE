import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		
module UART_MIKE 
(
	input logic clk,
	input logic n_rst,
	input logic [UART_DATA_WIDTH-1:0] tx_data,
	input logic tx_send,
	input logic rx,
	input logic rx_flag_clr,	
	output logic  tx,
	output logic  parity_error,
	output logic  rx_flag,
	output logic  [UART_DATA_WIDTH-1:0] rx_data
);

// UART_MIKE_ctrl i_UART_MIKE_ctrl(
// 									.clk(clk),
// 									.n_rst(n_rst),
// 									.tx_send(tx_send_sync),
// 									.rx_start(rx_start),
// 									.rx_done(rx_done),
// 									.rx_flag_clr(rx_flag_clr),
// 									.tx_done(tx_done),
// 									.tx_inprg(tx_inprg2),
// 									.tx_data_cnt_delete(tx_data_cnt_delete2)
// );



logic rx_ff;
logic tx_send_sync; 

`MIKE_FF_NRST(rx_ff, rx, clk, n_rst)

rx_byte_stop rx_byte;
logic rx_clk_overflow;
logic rx_inprg;
logic rx_inprg_ff;
logic rx_clk_cnt_delete;
logic rx_counter_ov;
logic rx_data_cnt_delete;
logic [UART_FRAME_SIZE-1:0] rx_data_index;
logic [RX_CLOCK_SIZE-1:0] rx_clk_cnt_debug;
logic [RX_CLOCK_SIZE-1:0] rx_shift_val_debug;

logic rx_shift_en;
logic rx_shift_en_ff;

logic rx_done;
logic rx_done_nxt;
logic rx_done_ff;
logic rx_counter_done;
logic rx_counter_done_sticky;
logic rx_counter_done_sticky_ff;
logic shift_pulse_allign;
logic shift_pulse_allign_ff;
logic tx_clk_overflow;
logic [RX_CLOCK_SIZE-1:0] tx_clk_cnt_debug;

logic [UART_FRAME_SIZE-1:0] tx_index;
logic [UART_FRAME_SIZE-1:0] uart_data_width;

logic rx_flag_nxt;

logic pre_tx;
tx_byte_stop tx_byte;
logic tx_inprg;
logic tx_inprg_ff;
logic tx_data_cnt_delete;

logic tx_done;
logic tx_send_ff;
logic tx_send_ff2;

logic rx_flag_clr_sync;

`MIKE_FF_NRST(tx_send_ff, tx_send, clk, n_rst)
`MIKE_FF_NRST(tx_send_ff2, tx_send_ff, clk, n_rst)
`MIKE_FF_NRST(tx_inprg_ff, tx_inprg, clk, n_rst)

assign tx_send_sync = tx_send_ff & ~tx_send_ff2;

assign tx_inprg = (tx_send) ? 1'b1 : (tx_done) ? 1'b0 : tx_inprg_ff;
assign tx_data_cnt_delete = tx_inprg_ff & tx_done;

assign tx_byte.start = 1'b0;
assign tx_byte.tx_byte = tx_data;
assign tx_byte.parity = ^tx_data;
assign tx_byte.stop = 1'b1;

assign tx = (tx_send_sync | tx_inprg) ? pre_tx : 1'b1;

assign rx_flag_nxt = 	(rx_done_ff) 	? 1'b1 :
						(rx_flag_clr_sync) 	? 1'b0 :
										rx_flag;

`MIKE_FF_NRST(rx_flag_clr_sync, rx_flag_clr, clk, n_rst)

`MIKE_FF_NRST(rx_flag, rx_flag_nxt, clk, n_rst)
`MIKE_FF_NRST(rx_done_ff, rx_done, clk, n_rst)

// TEMPORAL TOD: FIXME: REMOVE
assign uart_data_width = 8;

//logic tx_inprg;
//logic [UART_DATA_SIZE-1:0] tx_data_cnt_val_debug;


`MIKE_FF_NRST(rx_inprg_ff, rx_inprg, clk, n_rst)
`MIKE_FF_NRST(rx_shift_en_ff, rx_shift_en, clk, n_rst)
`MIKE_FF_NRST(shift_pulse_allign_ff, shift_pulse_allign, clk, n_rst)

assign rx_start = (~rx) & (rx_ff) & (~rx_inprg_ff) & (~rx_flag);
assign rx_clk_cnt_delete = rx_done;
assign rx_data_cnt_delete = rx_done;
assign rx_counter_done = rx_counter_ov; // TODO: This is incorrect as it fires at the beginning of the sampling
assign rx_counter_done_sticky = (rx_counter_done) ? 			1'b1 :
								(rx_done | rx_done_ff) ? 		1'b0 :
													rx_counter_done_sticky_ff;

`MIKE_FF_NRST(rx_counter_done_sticky_ff, rx_counter_done_sticky, clk, n_rst)

// Reception is done sampling 
// This gets high when stop is received
assign rx_done = rx_counter_done_sticky_ff & rx_shift_en;

// Reception is in progrtess 
assign rx_inprg = (rx_start) ? 1'b1 : (rx_done) ? 1'b0 : rx_inprg_ff;

// Shift pulse allignment enable
assign shift_pulse_allign = (rx_clk_overflow)? 1'b1 : (rx_shift_en)? 1'b0 : shift_pulse_allign_ff;

counter #(
	.COUNTER_SIZE(UART_FRAME_SIZE)
)rx_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(rx_clk_overflow),
	.cnt_delete(rx_data_cnt_delete),
	.inc(1'b1),
	.count(rx_data_index),
	.overflow(rx_counter_ov),
	.cnt_goal(UART_FRAME_WIDHT-1) // UART_DATA_WIDTH - 1 + PARITY + STOP //NO START INCLUDED HERE
);


//Pulse counter
counter #(
	.COUNTER_SIZE(RX_CLOCK_SIZE)
)rx_clk_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(rx_inprg),
	.cnt_delete(rx_clk_overflow | rx_done),
	.inc(1'b1),
	.count(rx_clk_cnt_debug),
	.overflow(rx_clk_overflow),
	.cnt_goal(RX_CLOCK_WIDTH)
);

// Counter used for capturing edge allignement (get UART data at the middle of the pulse) 
// rx_shift_enable pulse generator
counter #(
	.COUNTER_SIZE(RX_CLOCK_SIZE)
)rx_counter_shift_en(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(shift_pulse_allign), 
	.cnt_delete(rx_shift_en),
	.inc(1'b1),
	.count(rx_shift_val_debug),
	.overflow(rx_shift_en),
	.cnt_goal(RX_CLOCK_WIDTH/2) // This value can be edited in the future 
);

//Actual RX shift for getting the DATA
rx_shifter rx_shifter (
	.n_rst(n_rst),
	.clk(clk),
	.rx_shift(rx_shift_en),
	.rx(rx),
	.rx_byte(rx_byte),
	.rx_done(rx_done),	
	.rx_data_index(rx_data_index),
	.uart_data_width(uart_data_width)
);

counter #(
	.COUNTER_SIZE(UART_FRAME_SIZE)
)tx_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(tx_clk_overflow),
	.cnt_delete(tx_data_cnt_delete),
	.inc(1'b1),
	.count(tx_index),
	.overflow(tx_done),
	.cnt_goal(UART_FRAME_WIDHT) // give time to stop bit for being sent
);

//Pulse counter
counter #(
	.COUNTER_SIZE(RX_CLOCK_SIZE)
)tx_clk_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(tx_inprg),
	.cnt_delete(tx_clk_overflow),
	.inc(1'b1),
	.count(tx_clk_cnt_debug),
	.overflow(tx_clk_overflow),
	.cnt_goal(RX_CLOCK_WIDTH)
);

//Actual RX shift for getting the DATA
tx_shifter tx_shifter (
	.n_rst(n_rst),
	.clk(clk),
	.tx_shift(tx_clk_overflow),
	.tx_index(tx_index),
	.tx(pre_tx),
	.tx_byte(tx_byte),
	.uart_data_width(uart_data_width)
);


endmodule
