// ECE6370
// Author: Praneeth Reddy Mosali, PeopleSoft ID: 1638989
// Load Register
// The load register holds the input and when the button is pressed or when there
// is a control signal then the output of the register equals the input.
// In this code when the load is 1 then the input of the register is sent to the 
// output of the register. 

module loadRegister(I, clk, rst, load, Q);
  input [3:0] I;
  input clk, rst, load;
  output [3:0] Q;
  reg [3:0] Q;
  

  always@(posedge clk) begin
    if(rst == 0)
      begin
	Q <= 4'b0000;
      end
    else
      begin
  	if(load == 1)
	  begin
  	    Q <= I;
	  end
      end
  end
endmodule
