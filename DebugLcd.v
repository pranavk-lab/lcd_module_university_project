module DebugLcd(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led);
input clk, rst;//general signals

//lcd
output reg rs_lcd,rw_lcd; 
output en_lcd;
output reg on_lcd;
reg en_oe, en_lcd_set;
inout [7:0]data_lcd;
reg oe;
reg [7:0] DataWrite;
assign data_lcd = oe ? DataWrite : 8'bz;//lcd
assign en_lcd = en_oe ? en_lcd_gen : en_lcd_set;//enable control
reg [4:0] count;


//states
reg [4:0]state, stateNext;

parameter DataWriteP = 4, DataWriteR = 5,DataWriteA = 6,DataWriteN = 7,DataWriteAA = 8,DataWriteV = 9, GoHome = 4'ha, TriggerDelay = 4'hb, SetupDelay = 4'hc, DataWritePr = 4'hd;
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
			red_led <= 1'b1;
			green_led <= 1'b0;
			oe <= 1'b1;
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
								else
								begin
									state <= FirstStep;
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
								else
								begin
									state <= SecondStep;
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
									state <= DataWriteP;
								
								end
								else
								begin
									state <= ThirdStep;
								end
						
							end
			
											
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
																					DataWrite <= 8'b00100000;
																					en_lcd_set <= 1'b0;
																					
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWritePr;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteP;
																					
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
																						state <= SetupDelay;
																						stateNext <= DataWriteA;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteR;
																					
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
																						state <= SetupDelay;
																						stateNext <= DataWriteN;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteA;
																					
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
																						state <= SetupDelay;
																						stateNext <= DataWriteAA;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteN;
																					
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
																						state <= SetupDelay;
																						stateNext <= DataWriteV;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteAA;
																					
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
																						state <= SetupDelay;
																						stateNext <= GoHome;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteV;
																					
																				end
																			
																		
																		end
													DataWritePr : begin
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
																					DataWrite <= 8'b01010000;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteR;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWritePr;
																					
																				end
																			
																		
																		end
													GoHome : begin
																	en_oe <= 1'b0;
																	en_lcd_set <= 1'b0;
																	
																	state <= GoHome;
																		end
													/*GoNextLine : begin
																		en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b0;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b11000000;
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
																			
																		
																		end*/
													TriggerDelay: begin
																			if(FlagHold == 1'b1)
																			begin
											
																					
																					count <= count +1;//to make sure data holds after enable is gnded
																					en_lcd_set <= 1'b0;
																					if(count == 5'b11111)
																					begin
																					state <= stateNext;
																					
																					DisableLatch <= 1'b1;
																					end
																			end
																			else
																			begin
																					
																					state <= TriggerDelay;
																				
																			 end
																			 
																					
			
																		end
													SetupDelay : begin
																			      if(FlagSetup == 1'b1)
																					begin
																						
																						en_lcd_set <= 1'b1;
																						count <= 5'b00000;
																						state <= TriggerDelay;
																						
																						DisableSetup <= 1'b1;
																					end
																					else
																					begin
																						
																						state <= SetupDelay;
																					end
																				
																					
																			
																		end					
																	
												
												
												
											
											 
				default : begin state <= FirstStep;
										en_oe <= 1'b1;
										
										end
			endcase//end case-1
		end//end else reset == 1
end//end always

endmodule
									