//IN ROM PWD WE HAVE [2:0] ADRESS INPUT AND [15:0] PWD OUTPUT
//NEED TO IMPLEMENT LOGOUT
module passwordManager(clk, rst, pwdOut, pass_Adrs, Pwd1,  Pwd2, Pwd3, Pwd4, passChecked);
  input clk, rst, pwdOut;
  input [2:0] pass_Adrs;
  input [3:0] Pwd1,  Pwd2, Pwd3, Pwd4;
  
  output passChecked;
  reg passChecked;
  
  reg [15:0] PWD;
  wire [15:0] ROMpass_out;

  parameter INITIAL = 0, ST1 = 1, ST2 = 2, ST3 = 3, ST4 = 4, ST5 = 5;
  reg [3:0] State, counter;
  ROM_Password R2(pass_Adrs, clk, ROMpass_out);
  always@(posedge clk)
  begin
    if(rst == 0)
    begin
      passChecked <= 0;
      State <=INITIAL;
    end
    else
    begin
      case(State)
      INITIAL:
      begin
        passChecked <= 0;
        if(pwdOut == 1)
        begin
          PWD[3:0] <= Pwd4; PWD[7:4] <= Pwd3; PWD[11:8] <= Pwd2; PWD[15:12] <= Pwd1;
          State <= ST1;
        end
        else
          State <= INITIAL;
      end      
      ST1:
      begin
        if(PWD == ROMpass_out)
        begin
          passChecked <= 1'b1;
        end
      end
      endcase
    end
  end
endmodule
        



