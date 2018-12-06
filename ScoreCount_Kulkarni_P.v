module ScoreCount_Kulkarni_P(clk, rst, ReConfig, RxDoNotBorrow, TxDoNotBorrow, Txrts, Rxrts, Digit_disp);
input clk, rst, RxDoNotBorrow, Rxrts, ReConfig;
output TxDoNotBorrow, Txrts;

output [3:0]Digit_disp; 
reg TxDoNotBorrow, Txrts, flag1s;
reg state;
reg [3:0] count;
parameter ReConfigure_timer = 0, ActiveCounter = 1;

always@(posedge clk)
begin
	if(rst == 1'b0 || ReConfig == 1'b1)
	begin
		count <= 4'b0000;
		state <= ActiveCounter;
		TxDoNotBorrow <= 1'b0;
		Txrts <= 1'b0;
	end
	else
	begin
		case(state)
			ReConfigure_timer : begin//top level module will be designed such that only if unit timer outputs do not borrow, the timer can be reconfigured
					    if(ReConfig == 1'b1)
					    begin
						count <= 4'b0000;
						state <= ActiveCounter;
					    end
					    else
						state <= ReConfigure_timer;
					    end
				
			ActiveCounter : begin
						if(RxDoNotBorrow == 1'b0)//if 0 then count else do not count
						begin
							Txrts <= 1'b0;
							if(Rxrts == 1'b1)
							begin
								state <= ActiveCounter;
								if(count != 4'b1001)
								begin
									Txrts <= 1'b0;
									count <= count + 1;
								end
								else
								begin
									Txrts <= 1'b1;
									count <= 4'b0000;
								end
							end
						end
						else
						begin
							if(Rxrts == 1'b1)
							begin
								
								if(count != 4'b1000&& count !=4'b1001)
								begin
									Txrts <= 1'b0;
									count <= count + 1;
									state <= ActiveCounter;
								end
								else
								begin	
									Txrts <= 1'b0;
									state <= ReConfigure_timer;
									TxDoNotBorrow <= 1'b1;
									count <= 4'b1001;

								end
							end	
						end
					end
			default : begin
					state <= ReConfigure_timer;
				  end
		endcase
	end
end
assign Digit_disp = count;
endmodule					
