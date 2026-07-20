module UART #( parameter BITS= 'd8)
(
    input logic  rx,
    input logic clock,reset,
    output logic  tx
);
wire [BITS-1:0]  rx_dout;
wire s_tick, rx_done;


RX  #(.BITS('d8))
RX
(
    .rx(rx),
    .s_tick(s_tick),
    .rx_dout(rx_dout),
    .rx_done(rx_done),
    .reset(reset),
    .clock(clock)  
);

TX #(.BITS('d8))
TX
(
  .tx(tx),    
  .s_tick(s_tick),
  .tx_din(rx_dout),
  .tx_start(rx_done),
  .reset(reset),
  .clock(clock)
);

BaudRate #(.BaudRate('d9600),
          .freq ('d100000000),
          .BITS('d8))
 BaudRate
(
    .done(s_tick),
    .reset(reset), 
    .clock(clock)
);


endmodule