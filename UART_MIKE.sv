import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		
module UART_MIKE 
(
	input clk,
	input n_rst,
	input [UART_DATA_WIDTH-1:0] tx_data,
	input tx_send,
	input rx,
	input rx_flag_clr,	
	output tx,
	output parity_error,
	output rx_flag,
	output [UART_DATA_WIDTH-1:0] rx_data
);

UART_MIKE_ctrl i_UART_MIKE_ctrl(
									.clk(clk),
									.n_rst(n_rst),
									.tx_send(tx_send),
									.rx_start(rx_start),
									.rx_done(rx_done),
									.rx_flag_clr(rx_flag_clr)
);



logic rx_ff;

`MIKE_FF_NRST(rx_ff, rx, clk, n_rst)


logic rx_clk_overflow;
logic rx_inprg;
logic rx_inprg_ff;
logic rx_clk_cnt_delete;
logic [UART_DATA_WIDTH-1:0] rx_byte;
logic rx_counter_ov;
logic rx_data_cnt_delete;
logic [UART_DATA_SIZE:0] rx_data_cnt_val_debug;
logic [RX_CLOCK_SIZE-1:0] rx_clk_cnt_debug;
logic [UART_DATA_SIZE:0] rx_shift_val_debug;
logic rx_shift_en;
logic rx_shift_en_ff;

logic shift_pulse_allign;
logic shift_pulse_allign_ff;

`MIKE_FF_NRST(rx_inprg_ff, rx_inprg, clk, n_rst)
`MIKE_FF_NRST(rx_shift_en_ff, rx_shift_en, clk, n_rst)
`MIKE_FF_NRST(shift_pulse_allign_ff, shift_pulse_allign, clk, n_rst)

assign rx_start = (~rx) & (rx_ff) & (~rx_inprg_ff);
assign rx_clk_cnt_delete = rx_done;
assign rx_data_cnt_delete = 1'b0;
assign rx_done = rx_counter_ov;


assign rx_inprg = (rx_start) ? 1'b1 : (rx_done) ? 1'b0 : rx_inprg_ff;

assign shift_pulse_allign = (rx_clk_overflow)? 1'b1 : (rx_shift_en)? 1'b0 : shift_pulse_allign_ff;

counter #(
	.COUNTER_WIDTH(UART_DATA_WIDTH),
	.COUNTER_SIZE(UART_DATA_SIZE+1),
	.COUNTER_GOAL(UART_DATA_WIDTH)
)rx_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(rx_clk_overflow),
	.cnt_delete(rx_data_cnt_delete),
	.count(rx_data_cnt_val_debug),
	.overflow(rx_counter_ov)
);


//Pulse counter
counter #(
	.COUNTER_WIDTH(RX_CLOCK_WIDTH),
	.COUNTER_SIZE(RX_CLOCK_SIZE),
	.COUNTER_GOAL(RX_CLOCK_WIDTH) 
)rx_clk_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(rx_inprg),
	.cnt_delete(rx_clk_cnt_delete),
	.count(rx_clk_cnt_debug),
	.overflow(rx_clk_overflow)
);

//Counter used for capturing edge allignement 
counter #(
	.COUNTER_WIDTH(RX_CLOCK_WIDTH),
	.COUNTER_SIZE(RX_CLOCK_SIZE+1),
	.COUNTER_GOAL(RX_CLOCK_WIDTH/2)
)rx_counter_shift_en(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(shift_pulse_allign),
	.cnt_delete(rx_shift_en),
	.count(rx_shift_val_debug),
	.overflow(rx_shift_en)
);

//Actual RX shift for getting the DATA
rx_shifter rx_shifter (
	.n_rst(n_rst),
	.clk(clk),
	.rx_shift(rx_shift_en),
	.rx(rx),
	.rx_byte(rx_byte)
);

endmodule

