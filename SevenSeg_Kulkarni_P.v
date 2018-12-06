//ECE6370
//Pranav Krishnaji Kulkarni
//Seven segment 
//Converts 4 bits to 7 bits that can be used to operate the 7 segment display. The seven segment displays the number described by the 7 bits
//the leds in the seven segment display are active low i.e. the led's glow only when given input is 0.
module SevenSeg_Kulkarni_P(bits_in,seg_out);
  input [3:0]bits_in;
  output [6:0]seg_out;
  reg [6:0]seg_out;

  always @(bits_in)
    begin
      case(bits_in)
        4'h0 : begin seg_out = 7'b1000000; end
	4'h1 : begin seg_out = 7'b1111001; end
	4'h2 : begin seg_out = 7'b0100100; end
	4'h3 : begin seg_out = 7'b0110000; end
	4'h4 : begin seg_out = 7'b0011001; end
	4'h5 : begin seg_out = 7'b0010010; end
	4'h6 : begin seg_out = 7'b0000010; end
	4'h7 : begin seg_out = 7'b1111000; end
	4'h8 : begin seg_out = 7'b0000000; end
	4'h9 : begin seg_out = 7'b0011000; end
	4'hA : begin seg_out = 7'b0001000; end
	4'hB : begin seg_out = 7'b0000011; end
	4'hC : begin seg_out = 7'b1000110; end
	4'hD : begin seg_out = 7'b0100001; end
	4'hE : begin seg_out = 7'b0000110; end
	4'hF : begin seg_out = 7'b0001110; end
	default : begin seg_out = 7'b1111111; end
	endcase
    end
endmodule  	
	