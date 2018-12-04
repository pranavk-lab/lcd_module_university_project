module DebugLcd(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led, BotNextLine, BotNew);
input clk, rst;//general signals

//debug
input BotNextLine, BotNew;


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
reg GoVariable, GoBack;

//states
reg [5:0]state, stateNext;

parameter DataWrite_ = 4, DataWriteU = 5,DataWriteE = 6,DataWriteS = 7,DataWriteT = 8,DataWriteI = 9, GoHome = 5'd10, TriggerDelay = 5'd11, SetupDelay = 5'd12, DataWriteQ = 5'd13, GoNextLine = 5'd14, AddressChangeDelay = 5'd15, DataWriteO = 5'd16, DataWriteN = 5'd17, VariableData = 5'd18;
parameter FirstStep = 0, SecondStep = 1, ThirdStep = 2, InitializationComplete = 3;


//counter
reg EnableCount = 1'b1;
reg EnableSetup, DisableSetup, EnableLatch, DisableLatch, disable_en, EnableAddress, DisableAddress;
wire flag1ms, flag15ms, flag5ms, flag100us, flag1ms_5ms, FlagSetup, FlagHold, en_lcd_gen, FlagAddress;


//debug red led
output reg red_led, green_led;


//Instantiation of delay elements

timer_15ms gen15ms(en_lcd_gen, rst, EnableCount,flag15ms);//special counter
timer_5ms gen5ms(en_lcd_gen, rst, flag15ms, flag5ms);//special counter
timer100u gen100us(en_lcd_gen, rst, flag5ms, flag100us);//special counter
timer4u genenable(clk, rst, EnableCount, en_lcd_gen);//enablegen
TimerSetup SetupDelay_instance(clk, rst, EnableSetup, DisableSetup, FlagSetup);//special counter can be reset by both rst and DisableCounter
TimerLatch GenLatchDelay(clk, rst, EnableLatch, DisableLatch, FlagHold);//special counter can be reset by both rst and DisableLatch
AddressDelay GenAddressDelay(clk, rst, EnableAddress, DisableAddress, FlagAddress);
BottonLogic_Kulkarni_P GenNextLine(clk, BotNextLine, NextLinePulse, rst);
BottonLogic_Kulkarni_P GenNewWord(clk, BotNew, NewPulse, rst);

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
									state <= DataWrite_;
								
								end
								else
								begin
									state <= ThirdStep;
								end
						
							end
			
											
													DataWrite_ : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				en_lcd_set <= 1'b1;
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
																						stateNext <= DataWriteQ;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWrite_;
																					
																				end
																			
																		
																		end
													DataWriteU : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010101;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteE;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteU;
																					
																				end
																			
																		
																		end
													DataWriteE :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01000101;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteS;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteE;
																					
																				end
																			
																		
																		end
													DataWriteS :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010011;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteT;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteS;
																					
																				end
																			
																		
																		end
													DataWriteT :begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010100;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteI;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteT;
																					
																				end
																			
																		
																		end
													DataWriteI : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01001001;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteO;
																						
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteI;
																					
																				end
																			
																		
																		end
													DataWriteQ : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01010001;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteU;
																					EnableAddress <= 1'b1;
																					DisableAddress <= 1'b0;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteQ;
																					
																				end
																			
																		
																		end
													DataWriteO : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin
																					oe <= 1'b1;
																					rs_lcd <= 1'b1;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b01001111;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= DataWriteN;
																					EnableAddress <= 1'b1;
																					DisableAddress <= 1'b0;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteO;
																					
																				end
																			
																		
																		end
													DataWriteN : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
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
																						stateNext <= GoHome;
																					EnableAddress <= 1'b1;
																					DisableAddress <= 1'b0;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= DataWriteN;
																					
																				end
																			
																		
																		end
													VariableData : begin
																				en_oe <= 1'b0;
																				oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				en_lcd_set <= 1'b1;
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
																						stateNext <= GoHome;
																					EnableAddress <= 1'b1;
																					DisableAddress <= 1'b0;
																				  DisableSetup <= 1'b0;
																				end
																				else
																				begin
																					state <= VariableData;
																					
																				end
																			
																		
																		end
													GoHome : begin
																	en_oe <= 1'b0;
																	en_lcd_set <= 1'b0;
																	if(NextLinePulse == 1'b1 && NewPulse == 1'b0)//go 40H address
																	begin
																	en_oe <= 1'b0;
																	oe <= 1'b1;
																	rs_lcd <= 1'b0;
																   rw_lcd <= 1'b0;
																	en_lcd_set <= 1'b0;
																	DataWrite <= 8'b11000000;
																	EnableLatch <= 1'b1;
																	DisableLatch <= 1'b0;
																	EnableSetup <= 1'b1;
																	state <= SetupDelay;
																	stateNext <= AddressChangeDelay;
																	DisableSetup <= 1'b0;
																	GoVariable <= 1'b1;
																	GoBack <= 1'b0;
																	end
																	else if(NextLinePulse == 1'b0 && NewPulse == 1'b1)//gohome
																	begin
																	en_oe <= 1'b0;
																	oe <= 1'b1;
																	rs_lcd <= 1'b0;
																   rw_lcd <= 1'b0;
																	en_lcd_set <= 1'b0;
																	DataWrite <= 8'b10000000;
																	EnableLatch <= 1'b1;
																	DisableLatch <= 1'b0;
																	EnableSetup <= 1'b1;
																	state <= SetupDelay;
																	stateNext <= AddressChangeDelay;
																	DisableSetup <= 1'b0;
																	GoVariable <= 1'b0;
																	GoBack <= 1'b1;
																	end
																	end
													GoNextLine : begin
																		en_oe <= 1'b0;
																				/*oe <= 1'b0;
																				rs_lcd <= 1'b0;
																				rw_lcd <= 1'b1;
																				if(data_lcd[7] == 1'b0)
																				begin*/
																					oe <= 1'b1;
																					rs_lcd <= 1'b0;
																					rw_lcd <= 1'b0;
																					
																					en_lcd_set <= 1'b0;
																					DataWrite <= 8'b11000000;
																					EnableLatch <= 1'b1;
																					DisableLatch <= 1'b0;
																					EnableSetup <= 1'b1;
																						state <= SetupDelay;
																						stateNext <= AddressChangeDelay;
																						
																				  DisableSetup <= 1'b0;
																				/*end
																				else
																				begin
																					state <= GoNextLine;
																					
																				end*/
																			
																		
																		end
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
																	
												
												AddressChangeDelay : begin
																				if(FlagAddress == 1'b1)
																				begin
																					if(GoBack == 1'b0 && GoVariable == 1'b1)//go 40H address
																					begin
																					state <= VariableData;
																					DisableAddress <= 1'b1;
																					green_led <= 1'b1;
																					end
																					else//go home
																					begin
																					state <= DataWrite_;
																					DisableAddress <= 1'b1;
																					green_led <= 1'b1;
																					end
																				end
																				else
																				begin
																					state <= AddressChangeDelay;
																					
																				end
																			end
												
											
											 
				default : begin state <= FirstStep;
										en_oe <= 1'b1;
										
										end
			endcase//end case-1
		end//end else reset == 1
end//end always

endmodule
									