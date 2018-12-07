module TopModule(clk, rst, data_lcd, rs_lcd, rw_lcd, en_lcd, on_lcd, GameStart, NextAlpha, red_led, green_led, Flag_led, SelectAlpha, red_led_controller, green_led_controller, Stabalize, CountUnit_7Seg, CountTenth_7Seg, TimerUnit_7Seg, TimerTenth_7Seg, pass_in, );
input clk, rst, GameStart, NextAlpha, SelectAlpha, Stabalize;
inout [7:0]data_lcd;
output rs_lcd, rw_lcd, en_lcd, on_lcd;
output red_led, green_led, red_led_controller, green_led_controller, Flag_led;
wire [7:0]DataGame;


//score wires
wire Rxdnb_score, Txdnb_unit_score, Txrts_score;
wire [3:0]ScoreUnit, UnitDigit, TenthDigit;
wire Txrts_tenth_score;
wire [3:0]ScoreTenth; 
output [6:0]CountUnit_7Seg, CountTenth_7Seg, TimerUnit_7Seg, TimerTenth_7Seg;
wire Txrts_tenth_timer;

DebugLcd lcd_module(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led, NextLinePulse, NewPulse, DataGame, read_done);//next line pulse only
GameController controller(clk, rst, GameStart, DataGame, read_done, NextLinePulse, NextAlpha, SelectAlpha, red_led_controller, green_led_controller, Flag_led, Stabalize, Score_increment, ReConfigCount, DoNotBorrow_unit, ReConfig_access);


//counter modules
ScoreCount_Kulkarni_P UnitCounter(clk, rst, ReConfigCount, Rxdnb_score, Txdnb_unit_score, Txrts_score, Score_increment, ScoreUnit);//Txdnb_unit_score is connected to nothing
ScoreCount_Kulkarni_P TenthCounter(clk, rst, ReConfigCount, 1'b1, Rxdnb_score, Txrts_tenth_score, Txrts_score, ScoreTenth);

//7 segment display counter
SevenSeg_Kulkarni_P UnitCDisp(ScoreUnit, CountUnit_7Seg);
SevenSeg_Kulkarni_P TenthCDisp(ScoreTenth, CountTenth_7Seg);


//Timer
Timer_Kulkarni_P UnitTimer(clk, rst, ReConfig_access, DoNotBorrow_tenth, DoNotBorrow_unit, rts_tenth, Flag1s, UnitDigit, UnitDigit_reconfig);//UnitDigit_reconfig are the switches that enter timer unit digits
Timer_Kulkarni_P TenthdgdfgdfTimer(clk, rst, ReConfig_access, 1'b1, DoNotBorrow_tenth, txrts_tenth_timer, rts_tenth, TenthDigit, TenthDigit_reconfig);//txrts_tenth_timer is floating wire
timer1s_Kulkarni_P gen1s(clk, rst, ReConfig_access, Flag1s, DoNotBorrow_unit);

SevenSeg_Kulkarni_P UnitTDisp(UnitDigit, TimerUnit_7Seg);
SevenSeg_Kulkarni_P TenthTDisp(TenthDigit, TimerTenth_7Seg);







//access controller
  input [3:0] pass_in;
  output greenLed, idLed, pwdLed, IDLED;
  output [6:0] passIn_disp;
  wire [15:0] ROM_ID;
  
  
  wire SelectAlpha_pulse, NextAlpha_pulse, reconfigButton_pulse, GameStart_pulse, idOut,pwdOut, idChecked, passChecked, TimerEnable;
  wire EnterAccess, NextAccess;
  wire [3:0] Out1, Out2, Out3, Out4, Pwd1, Pwd2, Pwd3, Pwd4;
  wire [2:0] pass_Adrs, i;
  
  buttonShaper Sh1(clk, rst, SelectAlpha, SelectAlpha_pulse);//password and enter answer
  buttonShaper Sh2(clk, rst, NextAlpha, NextAlpha_pulse);
  buttonShaper Sh3(clk, rst, reconfigButton, reconfigButton_pulse);//log out
  buttonShaper Sh4(clk, rst, GameStart, GameStart_pulse);
  
  accessController ac1(clk, rst, idChecked, passChecked, SelectAlpha_pulse, NextAlpha_pulse, reconfigButton_pulse, GameStart_pulse, pass_in, Out1, Out2, Out3, Out4,
                        Pwd1,  Pwd2, Pwd3, Pwd4, idOut, pwdOut, TimerEnable, EnterAccess, NextAccess, 
                        greenLed, idLed, pwdLed);
								
  passwordManager P1(clk, rst, pwdOut, pass_Adrs, Pwd1, Pwd2, Pwd3, Pwd4, passChecked);
  
  idManager ID1(clk, rst, idOut, passChecked, Out1, Out2, Out3, Out4, ROM_ID, idChecked, pass_Adrs, i, IDLED);
  ROM_User_ID R1(i, clk, ROM_ID);
  
  sevenSeg disp1(pass_in, passIn_disp);

endmodule 
