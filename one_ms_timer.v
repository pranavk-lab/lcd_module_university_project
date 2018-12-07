module one_ms_timer(Clk,Rst,Enable,onems_timer);
input Clk, Rst, Enable;
output reg onems_timer;

  reg [15:0] LFSR;
  wire feedback = LFSR[15];

 always @(posedge Clk)
  begin
if (Rst == 0) begin
 LFSR <= 0;
 onems_timer <= 0; end
else  begin
  if (Enable == 1) begin
    LFSR[0] <= feedback;
    LFSR[1] <= LFSR[0];
    LFSR[2] <= LFSR[1] ~^ feedback;
    LFSR[3] <= LFSR[2] ~^ feedback;
    LFSR[4] <= LFSR[3];
    LFSR[5] <= LFSR[4] ~^ feedback;
    LFSR[6] <= LFSR[5];
    LFSR[7] <= LFSR[6];
    LFSR[8] <= LFSR[7];
    LFSR[9] <= LFSR[8];
    LFSR[10] <= LFSR[9];
    LFSR[11] <= LFSR[10];
    LFSR[12] <= LFSR[11];
    LFSR[13] <= LFSR[12];
    LFSR[14] <= LFSR[13];
    LFSR[15] <= LFSR[14];
          if(LFSR == 16'b1001001001001001)begin
            onems_timer <= 1;
            LFSR <= 0; 
                   end
            else
            onems_timer <= 0; end
end
end                                          
endmodule