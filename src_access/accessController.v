module accessController(clk, rst, idChecked, passChecked, enterButton, nextButton, reconfigButton, startTimer, pass_in, Out1, Out2, Out3, Out4,
                        Pwd1,  Pwd2, Pwd3, Pwd4, idOut, pwdOut, TimerEnable, EnterAccess, NextAccess, greenLed, idLed, pwdLed);
  input clk, rst, idChecked, passChecked, enterButton, nextButton, reconfigButton, startTimer;
  input [3:0] pass_in;
 
	
  output idOut, pwdOut, TimerEnable, EnterAccess, NextAccess, greenLed, idLed, pwdLed;
  reg idOut, pwdOut, TimerEnable, EnterAccess, NextAccess, greenLed, idLed, pwdLed;

  output [3:0] Out1, Out2, Out3, Out4, Pwd1,  Pwd2, Pwd3, Pwd4;
  reg [3:0] Out1, Out2, Out3, Out4, Pwd1,  Pwd2, Pwd3, Pwd4;

  parameter INITIAL = 0, ST1 = 1, ST2 = 2, ST3 = 3, ST4 = 4, ST5 = 5, ST6 = 6;
  reg [3:0] State, counter;
  
  always@(posedge clk)
  begin
    if(rst == 0)
    begin
      Out1 <= 4'h0;Out2 <= 4'h0;Out3 <= 4'h0;Out4 <= 4'h0;
      Pwd1 <= 4'h0;Pwd2 <= 4'h0;Pwd3 <= 4'h0;Pwd4 <= 4'h0;
      idOut <= 1'b0;
      pwdOut <= 1'b0;    
      counter <= 4'h0;
      TimerEnable <= 1'b0;
      greenLed <= 1'b0;idLed <= 1'b0;pwdLed <= 1'b0;   

      State <= INITIAL;
          
    end
    else
    begin
      case(State)
      INITIAL:
      begin
        Out1 <= 4'h0;Out2 <= 4'h0;Out3 <= 4'h0;Out4 <= 4'h0;
        Pwd1 <= 4'h0;Pwd2 <= 4'h0;Pwd3 <= 4'h0;Pwd4 <= 4'h0;
        idOut <= 1'b0;
        pwdOut <= 1'b0;    
        counter <= 4'h0;
        TimerEnable <= 1'b0;
        greenLed <= 1'b0;idLed <= 1'b0;pwdLed <= 1'b0;
			
        State <= ST1;
      end
      ST1:
      begin
        if(enterButton == 1 && counter == 4'h0)
        begin
          Out1 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h1)
        begin
          Out2 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h2)
        begin
          Out3 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h3)
        begin
          Out4 <= pass_in;
          counter <= 4'h0;
          idOut <= 1'b1;
          State <= ST2;
        end         
      end
      ST2:
      begin
		  idLed <= idChecked;
      if(idChecked == 1)
      begin
        if(enterButton == 1 && counter == 4'h0)
        begin
          Pwd1 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h1)
        begin
          Pwd2 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h2)
        begin
          Pwd3 <= pass_in;
          counter <= counter + 1;
        end
        if(enterButton == 1 && counter == 4'h3)
        begin
          Pwd4 <= pass_in;
          counter <= 4'h0;
          pwdOut <= 1'b1;
          State <= ST3;
          pwdLed <= passChecked;
        end
      end
      
      end
      ST3:
      begin
        if(passChecked == 1)
        begin
          State <= ST4;
          greenLed <= 1'b1;
        end
        else if(enterButton == 1)
        begin 
          State <= ST2;
        end
      end

      ST4:
      begin
			TimerEnable <= startTimer;
        EnterAccess <= enterButton;
        NextAccess <= nextButton;
       
        if(reconfigButton == 1)
        begin
          State <= INITIAL;
			 
			 TimerEnable <= 1'b0;
        EnterAccess <= 1'b0;
        NextAccess <= 1'b0;
        end
        else
        begin
          State <= ST4;
        end
      end 
      default:begin State <= INITIAL; end      

      endcase
    end
  end
endmodule

      

  