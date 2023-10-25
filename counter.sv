import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		
module counter #(
	parameter COUNTER_WIDTH = 32,
	parameter COUNTER_SIZE = $clog2(COUNTER_WIDTH),
	parameter COUNTER_GOAL = 32
)(
	input n_rst,
	input clk,
	input cnt_en,
	input cnt_delete,
	output logic [COUNTER_SIZE-1:0] count,
	output logic overflow
);


logic [COUNTER_SIZE:0] count_ff;

`MIKE_FF_NRST(count_ff, count, clk, n_rst)

assign overflow = (count_ff ==  COUNTER_GOAL) ? 1'b1 : 1'b0;

always_comb begin 
	if (cnt_en) count = count_ff + 1'b1;
	else if (cnt_delete) count = 'b0;
	else			count = count_ff;
end



endmodule
