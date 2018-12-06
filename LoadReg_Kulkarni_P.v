//Pranav Kulkarni, 7179
//LoadReg
//Loads the incoming 4 bit input only at no reset and when the botton is pressed. Botton pressing has to first be converted to a single
//pulse over a clock period to avoid multiple loads for the same botton press  
module LoadReg_Kulkarni_P(LoadState, StoreState, clk, rst, BotPulse);
input [4:0]LoadState;
output [4:0]StoreState;
reg [4:0]StoreState;
input clk, rst, BotPulse;

always @(posedge clk)begin
  if (rst ==0)
    begin
      StoreState <= 4'b0000;
    end
  else 
    begin
      if (BotPulse ==1)
        begin
          StoreState <= LoadState;
        end
    end
end
endmodule

