`timescale 1ns / 1ps

module tb_tx();


 localparam BITS =8;
    localparam BaudRate= 9600;
    localparam BitPeriod=1000000000/BaudRate;
    localparam TickWait= BitPeriod/16;

logic s_tick, clock, reset, tx_start;  
logic [BITS-1:0] tx_din;            
logic tx  ;                            

TX #(.BITS(BITS))
dut
(
  .tx(tx),    
  .s_tick(s_tick),
  .tx_din(tx_din),
  .tx_start(tx_start),
  .reset(reset),
  .clock(clock)
);


initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
initial begin
        s_tick = 0;
        forever begin
        #(TickWait-10) s_tick = 1;
        #10  s_tick = 0;
        end
    end
    
  initial begin
        reset = 1; 
        tx_din=0;
        tx_start=0;
        
        #1000 reset = 0;   
        #2000; 
        tx_din='b01100001;
        #1000;
        tx_start=1;
        #10  tx_start=0;
        #(10*BitPeriod) ;
        #50000;
        $finish; 
    end

endmodule