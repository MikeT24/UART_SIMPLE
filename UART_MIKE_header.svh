
`define MIKE_FF(q, i, clk)			\
	always_ff @(posedge clk) q <= i  \


		
`define MIKE_FF_RST(q,i,clk,rst)		\
	always_ff @(posedge clk)					\
		begin																\
          if (rst) q <= '0 ;										\
			else q <= i ;												\
		end																	
		
`define MIKE_FF_NRST(q,i,clk,rst)		\
	always_ff @(posedge clk)					\
		begin																\
          if (~rst) q <= '0 ;										\
			else q <= i ;												\
		end																	