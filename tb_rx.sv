`timescale 1ns/1ps

module tb_rx();

    localparam BITS =8;
    localparam BaudRate= 9600;
    localparam BitPeriod=1/BaudRate;
    localparam TickWait= BitPeriod/16;
    
    logic rx, s_tick, reset, clock;
    logic rx_done;
    logic [BITS-1:0] rx_dout;

    RX  #(.BITS(BITS))dut (
        .rx(rx),
        .s_tick(s_tick),
        .rx_dout(rx_dout),
        .rx_done(rx_done),
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
        rx = 1; 
        
        #1000 reset = 0;
        
        #2000; 
        rx = 0; 
        #(BitPeriod) rx = 1 ;
        #(BitPeriod) rx = 0; 
        #(BitPeriod)  rx = 0;
        #(BitPeriod) rx = 0;
        #(BitPeriod)  rx = 0;
        #(BitPeriod) rx = 1;
        #(BitPeriod) rx = 1;  
        #(BitPeriod) rx = 0; 
        #(BitPeriod) rx = 1;
        #(BitPeriod);
        #50000;
        $finish; 
    end

endmodule