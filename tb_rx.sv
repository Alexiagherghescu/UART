`timescale 1ns/ 1ps

module tb_rx();

logic rx, s_tick, reset, rx_done, clock;
logic [7:0] rx_dout;

RX dut
(
    .rx(rx),
    .s_tick(s_tick),
    .rx_dout(rx_dout),
    .rx_done(rx_done),
    .reset(reset),
    .clock(clock)  
);


initial begin
    clock<=0;
    forever 
        begin
        #5 clock<= ~clock;
        end
end

initial begin
    reset<=1;
    s_tick<=0;
    rx<= 1'b0;
    
    #10 reset <= 0;
        s_tick <=1;
    #52083 rx<=0;
    #104166 rx<=0;
    #104166 rx<= 1;
    #104166 rx<=1;
    #104166 rx<=0;
    #104166 rx<=0;
    #104166 rx<=0;
    #104166 rx<=0;
    #104166 rx<=1;
    #52083 rx<=1;
    #200 rx<= 0; 

end

endmodule