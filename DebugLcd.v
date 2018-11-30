module DebugLcd(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led);
input clk, rst;//general signals

//lcd
output reg rs_lcd,rw_lcd; 
output en_lcd;
output on_lcd;
reg on_lcd = 1'b1;
inout [7:0]data_lcd;
reg oe;
reg [7:0] BusyFlag, DataWrite;
assign data_lcd = oe ? DataWrite : 1'bZ;//lcd




//states
reg [3:0]stateInitialized, stateNext;
reg [1:0] state;
parameter DataWriteP = 0, DataWriteR = 1,DataWriteA = 2,DataWriteN = 3,DataWriteAA = 4,DataWriteV = 5, GoHome = 6, RefreshDisplay = 7, LatchingDelay = 8;
parameter FirstStep = 0, SecondStep = 1, ThirdStep = 2, InitializationComplete = 3;


//counter
reg EnableCount = 1'b1;
reg EnableRefresh, DisableRefresh, EnableLatch, DisableLatch;
wire flag1ms, flag15ms, flag5ms, flag100us, flag1ms_5ms, flagHome, flagLatch;


//debug red led
output reg red_led, green_led;


//Instantiation of delay elements

timer_15ms gen15ms(en_lcd, rst, EnableCount,flag15ms);//special counter
timer_5ms gen5ms(en_lcd, rst, flag15ms, flag5ms);//special counter
timer100u gen100us(en_lcd, rst, flag5ms, flag100us);//special counter
timer4u genenable(clk, rst, EnableCount, en_lcd);
TimerHome RefreshRate(en_lcd, rst, EnableRefresh, DisableRefresh, flagHome);//special counter can be reset by both rst and DisableCounter
TimerLatch GenLatchDelay(clk, rst, EnableLatch, DisableLatch, flagLatch);//special counter can be reset by both rst and DisableLatch

always@(posedge clk)
begin
		if(rst == 1'b0)
		begin
			state <= FirstStep;
			stateInitialized <= DataWriteP;
			red_led <= 1'b1;
			green_led <= 1'b0;
		end
		else
		begin
			red_led <= 1'b0;
			case(state)
			FirstStep : begin
								if(flag15ms ==1'b1)//fuction set
								begin
									oe <= 1'b1;
									DataWrite <= 8'b00111011;
									rw_lcd	<= 1'b0;
									rs_lcd <= 1'b0;
									state <= SecondStep;
								
								end
							
							end
			SecondStep : begin
								if(flag5ms ==1'b1)//cursur on
								begin
									oe <= 1'b1;
									DataWrite <= 8'b00001110;
									rw_lcd <= 1'b0;
									rs_lcd <= 1'b0;
									state <= ThirdStep;
								end
						
							end
			ThirdStep : begin
								if(flag100us ==1'b1)// increment ram address by 1
								begin
									oe <= 1'b1;
									DataWrite <= 8'b00000110;
									rw_lcd <= 1'b0;
									rs_lcd <= 1'b0;
									state <= InitializationComplete;
								end
						
							end
			InitializationComplete : begin
												case(stateInitialized)
											
													DataWriteP : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01010000;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= DataWriteR;
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteP;
																			end
																		end
													DataWriteR : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																				   green_led <= 1'b1;
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01010010;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= DataWriteA;
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteR;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteR;
																			end
																		end
													DataWriteA : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01000001;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= DataWriteN;
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteA;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteA;
																			end
																		end
													DataWriteN : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01001110;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= DataWriteAA;
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteN;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteN;
																			end
																		end
													DataWriteAA : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01000001;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= DataWriteV;
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteAA;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteAA;
																			end
																		end
													DataWriteV : begin
																			if(en_lcd == 1'b1)
																			begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01010110;
																					EnableLatch <= 1'b1;
																						stateInitialized <= LatchingDelay;
																						stateNext <= RefreshDisplay;//changed for debug
																						state <= InitializationComplete;
																				  DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteV;
																					state <= InitializationComplete;
																				end
																			end
																			else
																			begin
																				state <= InitializationComplete;
																				stateInitialized <= DataWriteV;
																			end
																		end
													GoHome : begin
																	if(en_lcd == 1'b1)
																	begin
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b0;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b00000010;
																					EnableLatch <= 1'b1;
																					stateInitialized <= LatchingDelay;
																					stateNext <= DataWriteP;
																					state <= InitializationComplete;
																					DisableLatch <= 1'b0;
																				end
																				else
																				begin
																					DisableLatch <= 1'b1;
																					green_led<= 1'b0;
																					stateInitialized <= GoHome;
																					state <= InitializationComplete;
																					
																				end
																		end
																		end
													RefreshDisplay: begin
																					oe <= 1'b0;
																					rs_lcd <= 1'b0;
																					rw_lcd <= 1'b1;
																					stateInitialized <= RefreshDisplay;
																					state <= InitializationComplete;
																			      
																					/*
																					if(flagHome == 1'b1)
																					begin
																						DisableRefresh <= 1'b1;
																						stateInitialized <= DataWriteP;
																						state <= InitializationComplete;
																					end
																					else
																					begin
																						stateInitialized <= RefreshDisplay;
																						state <= InitializationComplete;
																					end
																					*/
																			
																		end
													LatchingDelay : begin
																			      
																					
																					if(flagLatch == 1'b1)
																					begin
																						DisableLatch <= 1'b1;
																						stateInitialized <= stateNext;
																						state <= InitializationComplete;
																					end
																					else
																					begin
																						stateInitialized <= LatchingDelay;
																						state <= InitializationComplete;
																					end
																					
																			
																		end					
																	
																
													default : begin 
																		oe <= 1'b0;//changed for debug
																		rs_lcd <= 1'b0;
																		rw_lcd <= 1'b1;
																		stateInitialized <= DataWriteP;
																		state <= InitializationComplete;
																			end
												endcase//end case-2
												
											
											 end//InitializationComplete state
				default : begin state <= FirstStep; end
			endcase//end case-1
		end//end else reset == 1
end//end always

endmodule
									