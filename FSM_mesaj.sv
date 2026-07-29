module FSM_mesja
(
    input logic full, message_inc, message_dec, message_reset, message_help,message_error, message_status, clock, reset,
    input logic [31:0] ascii_val,
    output logic [7:0]  data,
    output logic        data_valid,
    output logic start_bit
);


typedef enum logic [1:0] {
        START ,
        MESAJ,
        TRANSMISIE  
    } state_t;
 
 state_t state=START;

logic [599:0] shiftreg;
logic [7:0] counter_litera;


always @(posedge clock)
begin
    if(reset==1)
        begin
            data        <= 0;
            data_valid  <= 1'b0;
            state       <= START;
        end
    else 
    begin
    case(state)
            START:
             begin
                start_bit<=0;
                if(message_reset==1)
                   begin
                       shiftreg<={"RESET|Counter: 0x", ascii_val, "\r\n", 416'd0};
                       counter_litera<=23;
                        state<=MESAJ ;
                   end
                   
                else begin
                           if(message_inc==1 && message_dec==0)
                           begin
                              state<=MESAJ ;
                              shiftreg<={"INC|Counter: 0x", ascii_val, "\r\n",432'd0};
                              counter_litera<=21;
                           end
                           else
                                 begin
                                 if(message_inc==0 && message_dec==1)
                                     begin
                                      state<=MESAJ ;
                                      shiftreg<={"DEC|Counter: 0x", ascii_val, "\r\n",432'd0}; 
                                      counter_litera<=21;    
                                     end
                                 else
                                 if(message_status==1 && message_help==0 && message_inc==0 && message_dec==0  )
                                    begin
                                        state<=MESAJ;
                                        shiftreg<={"STATUS|Counter: 0x", ascii_val, "\r\n",408'd0};
                                        counter_litera<=24;
                                    end
                                 else
                                    begin
                                        if(message_help==1 &&message_status==0 && message_inc==0 && message_dec==0)
                                        begin
                                          state<=MESAJ;
                                          shiftreg<={"STATUS: S/s","\r\n", "INC Counter: I/i","\r\n", "DEC Counter: D/d","\r\n", "RESET Counter: R/r","\r\n","HELP:?"}  ;
                                          counter_litera<=75;
                                        end
                                       else if(message_error==1)
                                       begin
                                            state<=MESAJ;
                                            shiftreg<={"ERROR: Unknown","\r\n", 472'd0 };
                                            counter_litera<=16;
                                       end
                                       else begin
                                       state<=START;
                                       end
                                    end
                                 end
                        end  
                  end
           MESAJ:
           begin
            if(counter_litera==0) 
            begin
                state<= START;
            end
            else 
            begin
                start_bit<=1;
                counter_litera<=counter_litera-1;
                data        <=shiftreg[599:592];
                data_valid  <= 1'b1;
                shiftreg <=shiftreg<<8;
                state<=TRANSMISIE;
            end
            
           end
           
           TRANSMISIE:
           begin
             data_valid  <= 1'b0;
             start_bit   <= 0;
             if(full==0)
             begin
                state<=MESAJ;
             end
             else
             begin
                state<=TRANSMISIE;
             end
           end
    
        endcase
    end
end

endmodule