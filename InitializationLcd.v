module InitializationLcd(clk, rst, EnableTimers, Initialized, lcd_data, lcd_rs, lcd_rw, en_lcd);
input clk, rst, EnableTimers;
output reg Initialized;
output en_lcd;
inout [7:0]lcd_data;
reg oe;
reg [7:0] DataWrite;
assign lcd_data = oe ? DataWrite : 1'bZ;//lcd
output reg lcd_rs, lcd_rw;//on_lcd is kept on outside the module
reg [1:0]state;
wire flag1ms, flag15ms, flag5ms, flag100us;
parameter FirstStep = 0, SecondStep = 1, ThirdStep = 2, InitializationComplete = 3;
lfsr_Kulkarni_P gen1ms(clk, rst, EnableTimers, flag1ms);
timer_15ms gen15ms(flag1ms, flag15ms, clk,rst);//special counter
timer_5ms gen5ms(flag1ms, flag5ms, clk, rst);//special counter
timer100u gen100us(clk, rst, flag5ms, flag100us);
timer4u genenable(clk, rst, EnableTimers, en_lcd);

always @(posedge en_lcd)
begin
	case(state)
		FirstStep : begin
							if(flag15ms ==1'b1)
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw	<= 1'b0;
								lcd_rs <= 1'b0;
								state <= SecondStep;
							end
							else
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw <= 1'b0;
								lcd_rs <= 1'b0;
								state <= FirstStep;
							end
						end
		SecondStep : begin
							if(flag1ms ==1'b1)
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw <= 1'b0;
								lcd_rs <= 1'b0;
								state <= ThirdStep;
							end
							else
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw <= 1'b0;
								lcd_rs <= 1'b0;
								state <= SecondStep;
							end
						end
		ThirdStep : begin
							if(flag100us ==1'b1)
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw <= 1'b0;
								lcd_rs <= 1'b0;
								state <= InitializationComplete;
							end
							else
							begin
								oe <= 1'b1;
								DataWrite <= 8'b00110000;
								lcd_rw <= 1'b0;
								lcd_rs <= 1'b0;
								state <= ThirdStep;
							end
						end
		InitializationComplete : begin Initialized <= 1'b1; 
												
											state <= InitializationComplete;
										 end
	endcase
end
endmodule
