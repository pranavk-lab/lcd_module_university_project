// ECE6370
// Author: Praneeth Reddy Mosali, PeopleSoft ID: 1638989
// Button Shaper Module
// When the button is pressed a single pulse signal is generated which can be
// fed to any other harware or can be used as a control signal.

//bIN == button Input
module buttonShaper(clk, rst, bIN, bOUT);
  input clk, rst;
  input bIN;
  output bOUT;
  reg bOUT;

  parameter S_OFF = 0, S_ON = 1,S_WAIT = 2;
  reg [1:0] State, StateNext;

  always @(State, bIN) begin
    case (State)
      S_OFF: begin
	bOUT <= 0;
	if (bIN == 1)
	  begin
	    StateNext <= S_OFF;
	  end
	else
	  begin
	    StateNext <= S_ON;
	  end
      end

      S_ON:begin
	bOUT <= 1;
	StateNext <= S_WAIT;
      end

      S_WAIT:begin
	bOUT <= 0;
	if(bIN ==0)
	  begin
	    StateNext <= S_WAIT;
	  end
	else
	  begin
	    StateNext <= S_OFF;
	  end
      end
      default:begin StateNext <= S_OFF; end
    endcase
  end

  always@(posedge clk)
    begin
      if(rst == 0)
	begin
	  State <= S_OFF;
	end      
      else
	begin
	  State <= StateNext;
	end
    end
endmodule      
  
  
         