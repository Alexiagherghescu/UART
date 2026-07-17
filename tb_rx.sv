`timescale 1ns/1ps

module tb_rx();

    logic rx, s_tick, reset, clock;
    logic rx_done;
    logic [7:0] rx_dout;

    RX dut (
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
        #6500 s_tick = 1;
        #10  s_tick = 0;
        end
    end
    
    
    
    initial begin
        reset = 1;
        rx = 1; 
        
        #1000 reset = 0;
        
        #2000; 
        rx = 0; 
        #104166 rx = 1 ;
        #104166 rx = 0; 
        #104166  rx = 0;
        #104166 rx = 0;
        #104166  rx = 0;
        #104166 rx = 1;
        #104166 rx = 1;  
        #104166 rx = 0; 
        #104166 rx = 1;
        #104166;
        #50000;
        $finish; 
    end

endmodule