import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		

module UART_MIKE_ctrl (
	input logic n_rst,
	input logic clk,
	input logic tx_send,
	input logic rx_start,
	input logic rx_done,
	input logic rx_flag_clr
	);
	

localparam IDLE			 = 0;
localparam RX_DATA 		 = 1;
localparam WAIT_FLG_CLR	 = 2; 
localparam TX_DATA		 = 3;
	
	
logic [2:0] state;
logic [2:0] nxt_state;

logic tx_data_cnt_en;
logic [UART_DATA_SIZE-1:0] tx_data_cnt_val_debug;
logic tx_counter_ov;
logic tx_data_cnt_delete;

	
`MIKE_FF_NRST(state, nxt_state, clk, n_rst)


//always_comb begin 
//	tx_data_cnt_en = 1'b0;
//	if (state == TX_DATA) begin 
//		tx_data_cnt_en = 1'b1;
//	end
//end

assign tx_data_cnt_en 		= ((nxt_state == TX_DATA) & (state == TX_DATA)) ? 1'b1 : 1'b0;
assign tx_data_cnt_delete	= ((nxt_state == IDLE) & (state == TX_DATA)) ? 1'b1 : 1'b0;

always_comb begin 
	nxt_state = state;
	case (state) 
		IDLE: begin
			if(tx_send & ~rx_start)	nxt_state = TX_DATA;	
			else if 	 (rx_start)					nxt_state = RX_DATA;
		end		
		RX_DATA: begin 
			if		 (rx_done)					nxt_state = WAIT_FLG_CLR;
		end
		WAIT_FLG_CLR: begin 
			if		 (rx_flag_clr)				nxt_state = IDLE;
		end
		TX_DATA: begin 
			if 	 (tx_counter_ov)			nxt_state = IDLE;	
		end
	endcase
end

counter #(
	.COUNTER_WIDTH(UART_DATA_WIDTH),
	.COUNTER_SIZE(UART_DATA_SIZE),
	.COUNTER_GOAL(UART_DATA_WIDTH-1)
)tx_counter(
	.n_rst(n_rst),
	.clk(clk),
	.cnt_en(tx_data_cnt_en),
	.cnt_delete(tx_data_cnt_delete),
	.count(tx_data_cnt_val_debug),
	.overflow(tx_counter_ov)
);




	
endmodule
	
	