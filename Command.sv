module command
(
    input logic [7:0] command,
    input logic reset, clock,
    output logic signal_inc, signal_dec, signal_reset, 
    output logic message_inc, message_dec, message_reset, message_help,message_error, message_status
);

always @(posedge clock)
begin
    if(reset==1)
        begin
            signal_inc<=0; 
            signal_dec<=0; 
            signal_reset<=0;                                               
            message_inc<=0; 
            message_dec<=0; 
            message_reset<=0; 
            message_help<=0;
            message_error<=0; 
            message_status<=0; 
        end
    else 
        begin
            signal_inc<=0; 
            signal_dec<=0; 
            signal_reset<=0;                                               
            message_inc<=0; 
            message_dec<=0; 
            message_reset<=0; 
            message_help<=0;
            message_error<=0; 
            message_status<=0; 
        
        case(command)
        
        "I","i" : 
            begin
                signal_inc<=1;
                message_inc<=1;  
            end
            
        "D", "d":
            begin
                signal_dec<=1;
                message_dec<=1; 
            end
        
         "R", "r":
            begin
                signal_reset<=1 ; 
                message_reset<=1; 
            end
         
          "S","s":
             begin
                 message_status<=1; 
             end
             
           "?" :
               begin
                 message_help<=1;   
               end
           default:
           begin
                message_error<=1;
           end
           
        endcase
        end

end

endmodule