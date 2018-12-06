module TopModule(clk, rst, data_lcd, rs_lcd, rw_lcd, en_lcd, on_lcd, GameStart, NextAlpha, red_led, green_led, Flag_led, SelectAlpha, red_led_controller, green_led_controller, Stabalize, CountUnit_7Seg, CountTenth_7Seg);
input clk, rst, GameStart, NextAlpha, SelectAlpha, Stabalize;
inout [7:0]data_lcd;
output rs_lcd, rw_lcd, en_lcd, on_lcd;
output red_led, green_led, red_led_controller, green_led_controller, Flag_led;
wire [7:0]DataGame;

//score wires
wire Rxdnb_score, Txdnb_unit_score, Txrts_score;
wire [3:0]ScoreUnit;
wire Txrts_tenth_score;
wire [3:0]ScoreTenth; 
output [6:0]CountUnit_7Seg, CountTenth_7Seg;


DebugLcd lcd_module(clk, rst, rs_lcd, rw_lcd, en_lcd, on_lcd,data_lcd, red_led, green_led, NextLinePulse, NewPulse, DataGame, read_done);//next line pulse only
GameController controller(clk, rst, GameStart, DataGame, read_done, NextLinePulse, NextAlpha, SelectAlpha, red_led_controller, green_led_controller, Flag_led, Stabalize, Score_increment, ReConfigCount);


//counter modules
ScoreCount_Kulkarni_P UnitCounter(clk, rst, ReConfigCount, Rxdnb_score, Txdnb_unit_score, Txrts_score, Score_increment, ScoreUnit);//Txdnb_unit_score is connected to nothing
ScoreCount_Kulkarni_P TenthCounter(clk, rst, ReConfigCount, 1'b1, Rxdnb_score, Txrts_tenth_score, Txrts_score, ScoreTenth);

//7 segment display counter
SevenSeg_Kulkarni_P UnitCDisp(ScoreUnit, CountUnit_7Seg);
SevenSeg_Kulkarni_P TenthCDisp(ScoreTenth, CountTenth_7Seg);
endmodule 
