module LFSR4_9(clock, q, rst);
  input clock, rst;
  output [1:0] q;

  reg [1:0] LFSR = 2'b11;
  wire feedback = LFSR[1];

  always @(posedge clock)
  begin
  if(rst == 1'b0)
  begin
		LFSR <= 2'b11;
	end
	else
	begin
       LFSR[0] <= feedback;
    LFSR[1] <= LFSR[0] ^ feedback;
	 end
  end

  assign q = LFSR;
endmodule
