module topModule(clk, rst, enterButton, nextButton, reconfigButton, startTimer, pass_in, passIn_disp, greenLed, idLed, pwdLed, IDLED);
  input clk, rst, enterButton, nextButton, reconfigButton, startTimer;
  input [3:0] pass_in;
  output greenLed, idLed, pwdLed, IDLED;
  output [6:0] passIn_disp;
  wire [15:0] ROM_ID;
  
  
  wire enterButton_pulse, nextButton_pulse, reconfigButton_pulse, startTimer_pulse, idOut,pwdOut, idChecked, passChecked, TimerEnable;
  wire EnterAccess, NextAccess;
  wire [3:0] Out1, Out2, Out3, Out4, Pwd1, Pwd2, Pwd3, Pwd4;
  wire [2:0] pass_Adrs, i;
  
  buttonShaper Sh1(clk, rst, enterButton, enterButton_pulse);
  buttonShaper Sh2(clk, rst, nextButton, nextButton_pulse);
  buttonShaper Sh3(clk, rst, reconfigButton, reconfigButton_pulse);
  buttonShaper Sh4(clk, rst, startTimer, startTimer_pulse);
  
  accessController ac1(clk, rst, idChecked, passChecked, enterButton_pulse, nextButton_pulse, reconfigButton_pulse, startTimer_pulse, pass_in, Out1, Out2, Out3, Out4,
                        Pwd1,  Pwd2, Pwd3, Pwd4, idOut, pwdOut, TimerEnable, EnterAccess, NextAccess, 
                        greenLed, idLed, pwdLed);
								
  passwordManager P1(clk, rst, pwdOut, pass_Adrs, Pwd1, Pwd2, Pwd3, Pwd4, passChecked);
  
  idManager ID1(clk, rst, idOut, passChecked, Out1, Out2, Out3, Out4, ROM_ID, idChecked, pass_Adrs, i, IDLED);
  ROM_User_ID R1(i, clk, ROM_ID);
  
  sevenSeg disp1(pass_in, passIn_disp);
endmodule
