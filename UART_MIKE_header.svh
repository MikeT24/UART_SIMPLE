
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


		
`define MIKE_FF_INIT_NRST(q,i,init,clk,rst)		\
	always_ff @(posedge clk)					\
		begin																\
          if (~rst) q <= init ;										\
			else q <= i ;												\
		end																			


`define MIKE_FF_EN_NRST(q,i,en,clk,rst)		\
	always_ff @(posedge clk)					\
		begin																\
        	if (~rst) q <= '0 ;										\
			else if (en) q <= i ;									\
			else q <= q ;												\
		end																	
