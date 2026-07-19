module TX
(
    input logic s_tick, clock, reset, tx_start,
    input logic [7:0] tx_din,
    output logic tx
);


typedef enum logic [1:0] {
        IDLE  ,
        START ,
        TRANSMISIE  ,
        STOP  
    } state_t;
 
 state_t state=IDLE;
 
 
 
 logic [7:0] shiftreg = 'b0;
 logic [2:0] bit_count= 'b0;
 logic [3:0] tick_count= 'b0;
 
 
always @(posedge clock)
begin
if (reset==1) begin
     shiftreg <= 0;
     bit_count<= 0; 
     tick_count<=0;
     state<=IDLE;
     tx<=1'b1;
 end
 
else begin
        case(state)
        IDLE: 
        begin
        tx <=1'b1;
            if(tx_start==1) 
                begin
                    state<= START;
                    shiftreg<= tx_din;
                    tick_count<=0;
                    bit_count<=0;   
                end
                
            else 
                 begin
                    state<=IDLE;
                 end
        end
        
        START:
        begin
        tx<= 1'b0;
            if(s_tick==1)
            begin
                if(tick_count==15)
                begin
                    state<= TRANSMISIE;
                    tick_count<=0;
                end
                else 
                begin
                    tick_count<= tick_count+1;
                end
            end
        end
       
       TRANSMISIE:
       begin
       tx<= shiftreg[bit_count];
       if(s_tick==1)
        begin
            if(tick_count==15)
                    begin
                    tick_count<=0;
                    if(bit_count==7)
                        begin
                            state<=STOP;
                            bit_count<=0;
                            
                        end
                        else
                            begin
                                 bit_count<=bit_count+1;
                            end
                    end
               
            else 
            begin
                tick_count<=  tick_count+1;
            end
        end
       end 
       STOP: 
       begin
       tx<=1'b1;
           if(s_tick==1)
            begin
                if(tick_count==15)
                    begin
                    state<=IDLE;
                    tick_count<=0;
                    end
                 else begin
                 tick_count<=tick_count+1;
                 end
                
            end
       end
        
        endcase 
 
end
end




endmodule