import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		

module UART_MIKE_ctrl (
	input logic n_rst,
	input logic clk,
	input logic tx_send,
	input logic rx_start,
	input logic rx_done,
	input logic rx_flag_clr,
	input logic tx_done,
	output logic tx_inprg,
	output logic tx_data_cnt_delete
	);
	

localparam IDLE			 = 0;
localparam RX_DATA 		 = 1;
localparam WAIT_FLG_CLR	 = 2; 
localparam TX_DATA		 = 3;
	
	
logic [2:0] state;
logic [2:0] nxt_state;



	
`MIKE_FF_NRST(state, nxt_state, clk, n_rst)


//always_comb begin 
//	tx_inprg = 1'b0;
//	if (state == TX_DATA) begin 
//		tx_inprg = 1'b1;
//	end
//end

assign tx_inprg 		= ((nxt_state == TX_DATA) & (state == TX_DATA)) ? 1'b1 : 1'b0;
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
			if 	 (tx_done)			nxt_state = IDLE;	
		end
	endcase
end




	
endmodule
	
	