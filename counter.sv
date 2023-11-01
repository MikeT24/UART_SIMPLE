import UART_MIKE_pkg::*;

`include "UART_MIKE_header.svh"				
		
		
module counter #(
	parameter COUNTER_SIZE = 8
)(
	input logic n_rst,
	input logic clk,
	input logic cnt_en,
	input logic cnt_delete,
	input logic inc,
	input logic  [COUNTER_SIZE-1:0] cnt_goal,
	output logic [COUNTER_SIZE-1:0] count,
	output logic overflow
);


logic [COUNTER_SIZE:0] count_ff;
logic [COUNTER_SIZE:0] init_val;

assign init_val = (inc) ? 'b0 : cnt_goal;

always_comb begin 
	if (inc) begin 
		if (count_ff ==  cnt_goal)	overflow = 1'b1;
		else							overflow = 1'b0;
	end
	else begin 
		if (count_ff == 'b0)			overflow = 1'b1;
		else							overflow = 1'b0;
	end
end 

`MIKE_FF_INIT_NRST(count_ff, count, init_val, clk, n_rst)

//`MIKE_FF_NRST(count_ff, count, clk, n_rst)

always_comb begin 
	if (cnt_en & ~cnt_delete) begin 
		if (inc) count = count_ff + 1'b1;
		else count = count_ff - 1'b1;
	end 
	else if (cnt_delete) begin
		if (inc) count = 'b0;
		else count = cnt_goal;
	end
	else begin
		 count = count_ff;
	end
end



endmodule
