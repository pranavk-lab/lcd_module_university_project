module GameController (clk, rst, GameBot, LCD_data, read_done, ReadPulse, NextBot, EnterBot, red_led, green_led, Flag_led, Stabalize, Score_increment, ReconfigCount);
wire [4:0]LFSR_alpha;
//wire [4:0]LFSR_sequence;
wire [1:0]sequence;
wire [7:0]ReadRom;
input read_done;
input NextBot, EnterBot;
input clk, rst;
output reg Score_increment;

output reg ReadPulse;
output reg red_led, green_led, Flag_led;
wire[4:0] RomAddress;
reg[7:0]RamAddress;
reg [7:0]SavedAddress;
wire [7:0]ReadRam;
reg [7:0]WriteRam;
input GameBot;//Start Timer input
reg wren, rden;
reg [3:0]state, stateNext;
parameter IDLE = 0, QuestionState = 1, AnswerState = 2, ReadAnswer = 3, ReadRandom = 4, SaveData = 5, SkipCycleRom = 6, SkipCycleRam = 7, ReadDoneAnswer = 8, ReadDoneRandom = 4'hd, FirstSequence = 9, SecondSequence = 4'ha, ThirdSequence = 4'hb, ForthSequence = 4'hc, SkipCycleRomQuestion = 4'he, DisplayAnswer = 4'hf;
output [7:0]LCD_data;
reg [7:0]LCD_data;
LFSR4_9 LFSR2(clk, sequence, rst);
LFSR_5 LFSR5(clk,LFSR_alpha, rst);
ROM_Alphabets ROM_READ(RomAddress, clk, ReadRom);
ram_1port_test RamAccess(RamAddress, clk, WriteRam, rden, wren, ReadRam); 
BottonLogic_Kulkarni_P GenNextLine(clk, NextBot, NextPulse, rst);
BottonLogic_Kulkarni_P EnterCorrectAnswer(clk, EnterBot, EnterPulse, rst);
BottonLogic_Kulkarni_P EnterGame(clk, GameBot, GameEnable, rst);
LoadReg_Kulkarni_P loadalpha(LFSR_alpha, RomAddress, clk, rst, LoadRomAddress);
//LoadReg_Kulkarni_P loadsequence(LFSR_sequence, sequence, clk, rst, LoadSequence);
reg [1:0]  count;
reg [1:0]SkipCount;
reg LoadRomAddress;
reg ScoreCount;
reg LoadData;
reg FlagGameOver;
reg LoadSequence;
input Stabalize;
reg [7:0]RamStore, RomStore;
output reg ReconfigCount;

always @(posedge clk)
begin
if(rst == 1'b0 || Stabalize == 1'b1)
begin
state <= IDLE;


end
else
begin
case(state)
IDLE: begin

		if(GameEnable == 1'b1)
		begin
			state <= QuestionState;
			SavedAddress <= 8'b00000001;
			ReconfigCount <= 1'b1;
		end
		else
		begin
			state <= IDLE;
			
		end
	end

QuestionState : begin
			LoadRomAddress <= 1'b1;
			state <= SkipCycleRomQuestion;
			stateNext <= SaveData;
			RamAddress <= SavedAddress;
			wren <= 1'b1;
			rden <= 1'b0;
			
			green_led <= 1'b0;
			red_led <= 1'b1;
			Score_increment <= 1'b0;
			SkipCount <= 1'b0;
			ReconfigCount <= 1'b0;
			
		end


SaveData : begin
		wren <= 1'b1;
		rden <= 1'b0;
		WriteRam <= ReadRom;
		RamStore <= ReadRom;
		state <= AnswerState;
	
		
	end
SkipCycleRomQuestion : begin
									SkipCount <= SkipCount + 1;
									LoadRomAddress <= 1'b0;
								if(SkipCount == 2'b11)
								begin
									state <= ReadRandom;
									FlagGameOver <= 1'b0;
								end
								else
								begin
									state <= SkipCycleRomQuestion;
								end
							end
					
SkipCycleRom : begin
		SkipCount <= SkipCount + 1;
		
		LoadRomAddress <= 1'b0;
		if(SkipCount == 2'b11)
		begin
			/*rden <= 1'b0;
			wren <= 1'b0;
			if(ReadRom == RamStore || ReadRom == RomStore)
				begin
					state <= ReadRandom;
					RomStore <= 8'b01111010;
					count <= count +1;
					Ram_led <= 1'b0;
			Rom_led <= 1'b0;
				end
			else
			begin*/
				state <= ReadRandom;
				count <= count + 1;
			//end
		end
		else
		begin
			state <= SkipCycleRom;
		end
	end
SkipCycleRam : begin
		SkipCount <= SkipCount + 1;
		
		if(SkipCount == 2'b11)
		begin
			state <= ReadAnswer;
			rden <= 1'b1;
			wren <= 1'b0;
			
			count <= count + 1;
		end
		else
		begin
			state <= SkipCycleRam;
		end
	end

				
AnswerState : begin
		red_led <= 1'b0;
		green_led <= 1'b1;
		
		if(RamAddress == 8'b00000000)
		begin
			state <= QuestionState;
			SavedAddress <= SavedAddress +1;
			Score_increment <= 1'b1;
		end
		else
		begin
		
		ScoreCount <= 1'b0;
		
		wren <= 1'b0;
		rden <= 1'b0;
		count <= 2'b00;
		if(sequence == 2'b00)
		begin
			state <= FirstSequence;
		end
		else if(sequence == 2'b01)
		begin
			state <= SecondSequence;
		end
		else if(sequence == 2'b10)
		begin
			state <= ThirdSequence;
		end
		else if(sequence == 2'b11)
		begin
			state <= ForthSequence;
		
		end
		else
		begin
			state <= AnswerState;
		end
		end
	end
FirstSequence : begin
		Flag_led <= 1'b0;
		LoadSequence <= 1'b0;
		//count <= count+1;
		
		if(count == 2'b00)
		begin
			state <= SkipCycleRam;
			SkipCount <= 2'b00;
			stateNext <= FirstSequence;
			FlagGameOver <= 1'b0;
		end
		else
		begin
			if(count != 2'b11)
			begin
				FlagGameOver <= 1'b0;
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				LoadRomAddress <= 1'b1;
				stateNext <= FirstSequence;
				
				rden <= 1'b1;
				wren <= 1'b0;
			end
			else
				begin
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				stateNext <= FirstSequence;
				LoadRomAddress <= 1'b1;
				
				FlagGameOver <= 1'b1;
				rden <= 1'b1;
				wren <= 1'b0;
				end
		end
		end
SecondSequence : begin
		//count <= count+1;
	
		Flag_led <= 1'b0;
		LoadSequence <= 1'b0;
		if(count == 2'b01)
		begin
			state <= SkipCycleRam;
			SkipCount <= 2'b00;
			stateNext <= SecondSequence;
			FlagGameOver <= 1'b0;
		end
		else
		begin
			if(count != 2'b11)
			begin
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				FlagGameOver <= 1'b0;
				LoadRomAddress <= 1'b1;
				stateNext <= SecondSequence;
				rden <= 1'b1;
				wren <= 1'b0;
				
			end
			else
			begin
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				stateNext <= SecondSequence;
				LoadRomAddress <= 1'b1;
				FlagGameOver <= 1'b1;
				rden <= 1'b1;
				wren <= 1'b0;
				
			end
		
		end
		end
ThirdSequence : begin
		//count <= count+1;
	
		Flag_led <= 1'b0;
		LoadSequence <= 1'b0;
		if(count == 2'b10)
		begin
			state <= SkipCycleRam;
			SkipCount <= 2'b00;
			stateNext <= ThirdSequence;
			FlagGameOver <= 1'b0;

		end
		else
		begin
			if(count != 2'b11)
			begin
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				FlagGameOver <= 1'b1;
				LoadRomAddress <= 1'b0;
				stateNext <= ThirdSequence;
				rden <= 1'b1;
				wren <= 1'b0;
				
			end
			else
			begin
				state <= SkipCycleRom;
				SkipCount <= 2'b00;
				stateNext <= ThirdSequence;
				LoadRomAddress <= 1'b1;
				FlagGameOver <= 1'b1;
				rden <= 1'b1;
				wren <= 1'b0;
				
			end
		
		
		end
		end
ForthSequence : begin
		//count <= count+1;
	
		Flag_led <= 1'b0;
		LoadSequence <= 1'b0;
		if(count == 2'b11)
		begin
			state <= SkipCycleRam;
			SkipCount <= 2'b00;
			FlagGameOver <= 1'b1;
			

		end
		else
		begin
			state <= SkipCycleRom;
			SkipCount <= 2'b00;
			stateNext <= ForthSequence;
			LoadRomAddress <= 1'b1;
			FlagGameOver <= 1'b0;
			rden <= 1'b1;
				wren <= 1'b0;
				
		end
		
		
		end

ReadAnswer : begin

			
			wren <= 1'b0;
			rden <= 1'b1;
			LCD_data <= ReadRam;
			
			ReadPulse <= 1'b1;
			
			if(read_done == 1'b1)
			begin
				state <= ReadDoneAnswer;
			end
			else
		   begin
				state <= ReadAnswer;
			end
			end
ReadDoneAnswer : begin		
			
			ReadPulse <= 1'b0;
			
			if(NextPulse == 1'b1 && EnterPulse == 1'b0) //|| TimerIndicator == 1'b1)
			begin
				if(FlagGameOver == 1'b1)
				begin
					state <= IDLE;//gameover
				end
				else
				begin
					state <= stateNext;
					
				end
			end
			else if(NextPulse == 1'b0 && EnterPulse == 1'b1)
			begin
				ScoreCount <= 1'b1;
				
				state <= AnswerState;
				RamAddress <= RamAddress - 1;
			end
			else
			begin
				state <= ReadDoneAnswer;
			end
			
            end
ReadDoneRandom : begin		
			
			ReadPulse <= 1'b0;
			
			if(NextPulse == 1'b1 && EnterPulse == 1'b0) //|| TimerIndicator == 1'b1)
			begin
				if(FlagGameOver == 1'b1)
				begin
					state <= IDLE;//gameover
				end
				else
				begin
					state <= stateNext;
					
				end
			end
			else if(NextPulse == 1'b0 && EnterPulse == 1'b1)
			begin
				
				if(ReadRom == RamStore)
				begin
					state <= AnswerState;
					RamAddress <= RamAddress - 1;
					
				end
				else
				begin
				
				state <= IDLE;//gameover
				end
			end
			else
			begin
				state <= ReadDoneRandom;
			end
			
            end
ReadRandom : begin
		   
			
			LCD_data <= ReadRom;
			ReadPulse <= 1'b1;
			
			if(read_done == 1'b1)
			begin
				state <= ReadDoneRandom;
			end
			else
		   begin
				state <= ReadRandom;
			end
			end
			
default : begin 
				state <= IDLE;
				SavedAddress <= 8'b00000001;	
			
		    end
endcase
end
end
endmodule
		