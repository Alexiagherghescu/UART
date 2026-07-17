module UART
(
    input logic  rx,
    input logic clock,reset,
    output logic  tx
);
wire [7:0]  rx_dout;
wire s_tick, rx_done;


RX RX
(
    .rx(rx),
    .s_tick(s_tick),
    .rx_dout(rx_dout),
    .rx_done(rx_done),
    .reset(reset),
    .clock(clock)  
);

TX TX
(
  .tx(tx),    
  .s_tick(s_tick),
  .tx_din(rx_dout),
  .tx_start(rx_done),
  .reset(reset),
  .clock(clock)
);

BaudRate BaudRate
(
    .done(s_tick),
    .reset(reset), 
    .clock(clock)
);


endmodule