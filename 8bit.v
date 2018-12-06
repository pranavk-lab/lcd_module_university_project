module LFSR_5(clock, q, rst);
  input clock, rst;
  output [4:0] q;

  reg [4:0] LFSR = 5'b11111;
  wire feedback = LFSR[4];

  always @(posedge clock)
  begin
	if (rst == 0)
		begin
			LFSR <= 5'b11111;
    		end
		else begin
	 LFSR[0] <= feedback;
    LFSR[1] <= LFSR[0];
    LFSR[2] <= LFSR[1] ^ feedback;
    LFSR[3] <= LFSR[2];
    LFSR[4] <= LFSR[3];
	end

  end

  assign q = LFSR;
endmodule