`timescale  1ns / 1ps


module tb_UART();

localparam BITS =8;                       
localparam BaudRate= 9600;                
localparam BitPeriod=1000000000/BaudRate; 
localparam TickWait= BitPeriod/16;        

logic reset, clock, tx, rx;


UART #(.BITS(BITS)) dut
(
     .rx(rx),
     .tx(tx),
     .clock(clock),
     .reset(reset) 
);

 initial begin
        clock = 0;
        forever #5 clock = ~clock;
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
    #(20*BitPeriod);                  
    $finish;              
end                       


endmodule