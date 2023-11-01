package UART_MIKE_pkg;

parameter UART_FRAME_WIDHT = 11;
parameter UART_FRAME_SIZE = $clog2(UART_FRAME_WIDHT); //INCLUDING START, PARITY AND STOP BIT 
parameter UART_DATA_WIDTH = 8; 
parameter UART_DATA_SIZE = $clog2(UART_DATA_WIDTH);
parameter BYTE = 8;

parameter RX_CLOCK_WIDTH = 10;
parameter RX_CLOCK_SIZE = $clog2(RX_CLOCK_WIDTH);
 


typedef enum {IDLE, RX_DATA, WAIT_FLG_CLR, TX_DATA} UART_FSM;

typedef struct packed {
    logic stop;
    logic parity;    
    logic [UART_DATA_WIDTH-1:0] rx_byte;
} rx_byte_stop;

typedef struct packed {
    logic stop;
    logic parity;
    logic [UART_DATA_WIDTH-1:0] tx_byte;
    logic start;
} tx_byte_stop;

endpackage
