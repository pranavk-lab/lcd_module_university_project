module DebugLcd(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led);
input clk, rst;//general signals

//lcd
output reg rs_lcd,rw_lcd; 
output en_lcd;
output on_lcd;
reg on_lcd;
reg rs_lcd_next, rw_lcd_next;
reg en_oe, en_lcd_set;
inout [7:0]data_lcd;
reg oe;
reg [7:0] BusyFlag, DataWrite, DataWrite_next;
assign data_lcd = oe ? DataWrite : 8'bz;//lcd
assign en_lcd = en_oe ? en_lcd_gen : en_lcd_set;//enable control
reg [4:0] count;


//states
reg [3:0]stateInitialized, stateNext;
reg [1:0] state;
parameter DataWriteP = 0, DataWriteR = 1,DataWriteA = 2,DataWriteN = 3,DataWriteAA = 4,DataWriteV = 5, GoHome = 6, TriggerDelay = 7, SetupDelay = 8;
parameter FirstStep = 0, SecondStep = 1, ThirdStep = 2, InitializationComplete = 3;


//counter
reg EnableCount = 1'b1;
reg EnableSetup, DisableSetup, EnableLatch, DisableLatch, disable_en;
wire flag1ms, flag15ms, flag5ms, flag100us, flag1ms_5ms, flagSetup, flagLatch, en_lcd_gen;


//debug red led
output reg red_led, green_led;


//Instantiation of delay elements

timer_15ms gen15ms(en_lcd_gen, rst, EnableCount,flag15ms);//special counter
timer_5ms gen5ms(en_lcd_gen, rst, flag15ms, flag5ms);//special counter
timer100u gen100us(en_lcd_gen, rst, flag5ms, flag100us);//special counter
timer4u genenable(clk, rst, EnableCount, en_lcd_gen);//enablegen
TimerSetup SetupDelay_instance(clk, rst, EnableSetup, DisableSetup, FlagSetup);//special counter can be reset by both rst and DisableCounter
TimerLatch GenLatchDelay(clk, rst, EnableLatch, DisableLatch, FlagHold);//special counter can be reset by both rst and DisableLatch

always@(posedge clk)
begin
		if(rst == 1'b0)
		begin
			state <= FirstStep;
			stateInitialized <= DataWriteP;
			red_led <= 1'b1;
			green_led <= 1'b0;
			oe <= 1'b0;
			rs_lcd <= 1'b0;
			rw_lcd <= 1'b0;
			on_lcd <= 1'b0;
			DataWrite <= 8'b00000001;
			
			en_oe <= 1'b1;
			
		end
		else
		begin
			on_lcd <= 1'b1;
			red_led <= 1'b0;
			case(state)
			FirstStep : begin
								
								if(flag15ms ==1'b1)//fuction set
								begin
									en_oe <= 1'b1;
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
									en_oe <= 1'b1;
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
									en_oe <= 1'b1;
									rw_lcd <= 1'b0;
									rs_lcd <= 1'b0;
									state <= InitializationComplete;
									
								end
						
							end
			InitializationComplete : begin
												case(stateInitialized)
											
													DataWriteP : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					DataWrite <= 8'b01010000;
																					en_lcd_set <= 1'b0;
																					
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= DataWriteR;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													DataWriteR : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					green_led <= 1'b1;
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010010;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= DataWriteA;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													DataWriteA :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01000001;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= DataWriteN;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													DataWriteN :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01001110;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= DataWriteAA;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													DataWriteAA :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01000001;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= DataWriteV;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													DataWriteV : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010110;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						stateInitialized <= SetupDelay;
																						stateNext <= GoHome;
																						state <= InitializationComplete;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					stateInitialized <= DataWriteP;
																					state <= InitializationComplete;
																				end
																			
																		
																		end
													GoHome : begin
																	en_oe <= 1'b0;
																	en_lcd_set <= 1'b0;
																	state <= InitializationComplete;
																	stateInitialized <= GoHome;
																		end
													TriggerDelay: begin
																			if(FlagHold == 1'b1)
																			begin
											
																					
																					count <= count +1;
																					en_lcd_set <= 1'b0;
																					if(count == 5'b11111)
																					begin
																					stateInitialized <= stateNext;
																					state <= InitializationComplete;
																					DisableLatch <= 1'b1;
																					end
																			end
																			else
																			begin
																					state <= InitializationComplete;
																					stateInitialized <= TriggerDelay;
																				
																			 end
																			 
																					
			
																		end
													SetupDelay : begin
																			      if(FlagSetup == 1'b1)
																					begin
																						
																						en_lcd_set <= 1'b1;
																						count <= 5'b00000;
																						stateInitialized <= TriggerDelay;
																						state <= InitializationComplete;
																						DisableSetup <= 1'b1;
																					end
																					else
																					begin
																						state <= InitializationComplete;
																						stateInitialized <= SetupDelay;
																					end
																				
																					
																			
																		end					
																	
																
													default : begin 
																		oe <= 1'b0;//changed for debug
																		en_oe <= 1'b0;
																		rs_lcd <= 1'b0;
																		rw_lcd <= 1'b1;
																		stateInitialized <= DataWriteP;
																		state <= InitializationComplete;
																			end
												endcase//end case-2
												
											
											 end//InitializationComplete state
				default : begin state <= FirstStep;
										en_oe <= 1'b1;
										end
			endcase//end case-1
		end//end else reset == 1
end//end always

endmodule
									