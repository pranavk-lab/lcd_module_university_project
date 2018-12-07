module counter(clk, rst, ip, op);
input clk, rst;
input  ip;
output reg op;
reg [3:0] count;

always @ (posedge clk)
      begin
          if(rst == 0)begin
             count <= 0;
             op <=0;end
        else begin
         if (ip == 1) begin
          if((count == 9) | (count > 9))begin
             count <= 0;
             op <= 1;end
          else  begin
           count <= count +4'b0001; 
               op <= 0; end
              end
          else
              op <= 0;
             end
      end
endmodule
