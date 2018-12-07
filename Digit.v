//ECE 6370 
// Abhinav K
// This is the verilog code for a BCD counter that counts down from 9-0 and intakes a configurable value from the user
module Digit (clk, rst, ip, DNB_ip, toggle, reconfigure, DNB_op, carry, disp);
input clk, rst, ip, DNB_ip, reconfigure;
input[3:0] toggle;
output reg DNB_op,carry;
output reg [3:0] disp;
reg State;
parameter S_1 = 0, S_2 = 1;

always@(posedge clk) begin
  if(rst == 0 )
    begin
         disp <= 0;
         carry <= 0;
         DNB_op <= 0;
         State <= S_1;
    end  
  else 
     begin
        case (State)
               S_1: begin
                    if(reconfigure == 1)
		     begin
                       disp <= toggle;
                       State <= S_2; 
		     end
                    else
		     begin
                       State <= S_1;
		     end
                    end
               S_2 : begin 
                     if(ip == 0) 
			begin
                         disp <= disp ;
                         carry <= 0; 
                         State <= S_2;
			end
                     else 
			begin
                        if (disp == 0) 
                         begin
                         if(DNB_ip == 0)
			  begin
                           disp <= 4'b1001;
                           carry <= 1; 
			  end
                         else 
			  begin
                           disp <= 0;
                           carry <= 0; 
			  end
                        end
                    else 
			begin
                        disp <= disp - 4'b001;
                          if(disp == 4'b0001 && DNB_ip == 1 ) 
			   begin
                             DNB_op <= 1;
                             State <= S_1; 
			   end
                          else 
			   begin
                           carry <= 0;
                           State <= S_2;
			   end
                         end
                      end
                    end                
          endcase
       end
end
endmodule
                 
                           
                       
                            
