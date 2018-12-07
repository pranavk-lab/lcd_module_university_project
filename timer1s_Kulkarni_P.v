module timer1s_Kulkarni_P(clk, rst, EnableTimer, TimeOut, DoNotBorrow);
input EnableTimer, clk, rst, DoNotBorrow;
output TimeOut;

reg TimeOut;
wire flag1ms;
reg [9:0]count;
Timer_1ms timer1ms(clk, rst, EnableTimer, flag1ms, DoNotBorrow);

always@(posedge clk)
begin
	if(rst == 1'b0)
	begin
		count <= 10'b0000000000;
	end
	else
	begin
		if(flag1ms == 1'b1)
		begin
			count <= count + 1;
			TimeOut <= 1'b0;
			
		end
		else
		begin
			if(count == 10'h3E8)
			begin
				count <= 10'b0000000000;
				TimeOut <= 1'b1;
			end
			else
			begin			
				TimeOut <= 1'b0;
			end
		end
	end
end
endmodule
