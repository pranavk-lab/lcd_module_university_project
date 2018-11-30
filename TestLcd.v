module Testlcd(clk, rst, lcd_code, lcd_en, lcd_on);
input clk, rst;
output [9:0]lcd_code;
output lcd_en, lcd_on;
reg lcd_en;
reg lcd_on = 1;

reg [9:0]lcd_code;
reg TimerIndicator;
reg [1:0] state;
reg [3:0] StateLcd;
reg [7:0] LFSR;
wire feedback = LFSR[7];
parameter IDLE = 0, CountState = 1, RestartCount = 2;
parameter LcdIdle = 0, FirstInitial = 1, SecondInitial = 2, ThirdInitial = 3, FirstAlpha = 4, SecondAlpha = 5, ThirdAlpha = 6, ForthAlpha = 7, FifthAlpha = 8, SixthAlpha = 9;
 always @(posedge clk)//1000ns timer
  begin
      
      if(rst == 0)
      begin
        LFSR <= 16'hff;
        TimerIndicator <= 1'b0;
        
      end
      else
        begin
	  case(state)
            IDLE : begin
                   LFSR <= 16'hff;
                   
                   
                   state <= CountState;
                   TimerIndicator <= 1'b0;
                   
                   
                   end
            CountState : begin
                             
     			     LFSR[0] <= feedback;
    				LFSR[1] <= LFSR[0];
    			LFSR[2] <= LFSR[1] ^ feedback;
    			LFSR[3] <= LFSR[2] ^ feedback;
    			LFSR[4] <= LFSR[3] ^ feedback;
    			LFSR[5] <= LFSR[4];
   			 LFSR[6] <= LFSR[5];
    			LFSR[7] <= LFSR[6];
                         if(LFSR == 8'h1c)//sequence that indicates 1000ns mark
                           begin
                             TimerIndicator <= 1'b1;
                             
			     lcd_en <= 1'b1;
                             end
                           else if(LFSR == 8'h24)
                            begin
                            TimerIndicator <= 1'b0;
                             state <= RestartCount;
			     lcd_en <= 1'b0;
                            end
                           else 
                             begin
                               TimerIndicator <= 1'b0;
                               state <= CountState;
                             end
 
			 end
         RestartCount : begin
                        
                        TimerIndicator <= 1'b0;//restart count if 1ms reached since 16 bit lfsr can count more than 1ms
                        state <= CountState;//the sequence would change everytime i.e. timer would be inaccurate
                        LFSR <= 16'he3;
                        end
	 
         default : begin
                   state <= IDLE;
                   end
         endcase
       end
end

always@(posedge TimerIndicator)
begin
 
 if (rst==0)
   begin
   StateLcd <= LcdIdle;
  
   end
 else
   begin
     case(StateLcd)
       LcdIdle : begin 
                   lcd_code <= 10'b0000000001;
                   StateLcd <= FirstInitial;
                 end
       FirstInitial : begin
                        lcd_code <= 10'b0000110000;
                        StateLcd <= SecondInitial;
                      end
       SecondInitial : begin
                        lcd_code <= 10'b0000001110;
                        StateLcd <= ThirdInitial;
                      end
	ThirdInitial : begin
                        lcd_code <= 10'b0000000110;
                        StateLcd <= FirstAlpha;
                      end
	FirstAlpha : begin
                        lcd_code <= 10'b1001010000;
                        StateLcd <= SecondAlpha;
                      end
	SecondAlpha : begin
                        lcd_code <= 10'b1001010010;
                        StateLcd <= ThirdAlpha;
                      end
	ThirdAlpha : begin
                        lcd_code <= 10'b1001000001;
                        StateLcd <= ForthAlpha;
                      end
	ForthAlpha : begin
                        lcd_code <= 10'b1001001110;
                        StateLcd <= FifthAlpha;
                      end
	FifthAlpha : begin
                        lcd_code <= 10'b1001000001;
                        StateLcd <= SixthAlpha;
                      end
	SixthAlpha : begin
                        lcd_code <= 10'b1001000001;
                        
                     end
	default : begin StateLcd <= LcdIdle;end
    endcase
  end
end
endmodule
