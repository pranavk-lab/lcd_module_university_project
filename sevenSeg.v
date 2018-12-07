// ECE6370
// Author: Praneeth Reddy Mosali, PeopleSoft ID: 1638989
// Seven Segment Decoder.
// Decodes the input and gives the output as a number or letter depending on the input 

module sevenSeg(segInput, segOutput);
  input [3:0] segInput;
  output [6:0] segOutput;
  reg [6:0] segOutput;
  
  always @ (segInput)
    begin
	case(segInput)
	  4'b0000:begin segOutput = 7'b100_0000; end
	  4'b0001:begin segOutput = 7'b111_1001; end
	  4'b0010:begin segOutput = 7'b010_0100; end
	  4'b0011:begin segOutput = 7'b011_0000; end
	  4'b0100:begin segOutput = 7'b001_1001; end
	  4'b0101:begin segOutput = 7'b001_0010; end
	  4'b0110:begin segOutput = 7'b000_0010; end
	  4'b0111:begin segOutput = 7'b111_1000; end
	  4'b1000:begin segOutput = 7'b000_0000; end
	  4'b1001:begin segOutput = 7'b001_1000; end
	  4'b1010:begin segOutput = 7'b000_1000; end
	  4'b1011:begin segOutput = 7'b000_0011; end
	  4'b1100:begin segOutput = 7'b100_0110; end
	  4'b1101:begin segOutput = 7'b010_0001; end
	  4'b1110:begin segOutput = 7'b000_0110; end
	  4'b1111:begin segOutput = 7'b000_1110; end
	  default:begin segOutput = 7'b111_1111; end
	endcase
    end
endmodule
	  