package UART_MIKE_pkg;


parameter UART_DATA_WIDTH = 8;
parameter UART_DATA_SIZE = $clog2(UART_DATA_WIDTH);
parameter BYTE = 8;

parameter RX_CLOCK_WIDTH = 10;
parameter RX_CLOCK_SIZE = $clog2(RX_CLOCK_WIDTH);
 


typedef enum {IDLE, RX_DATA, WAIT_FLG_CLR, TX_DATA} UART_FSM;

endpackage
