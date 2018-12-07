//IN ROM ID WE HAVE [2:0] INPUT AND [3:0] OUTPUT
module idManager(clk, rst, idOut, passOut, Out1, Out2, Out3, Out4, ROM_ID, idChecked, pass_Adrs,i, IDLED);
  input clk, rst, idOut, passOut;
  input [3:0] Out1, Out2, Out3, Out4;
  input [15:0] ROM_ID;
  
  output idChecked, IDLED;
  reg idChecked, IDLED;
  output [2:0] pass_Adrs,i;
  reg [2:0] pass_Adrs,i;
  
  reg [15:0] ID;
  //reg [2:0] i;
  
  parameter INITIAL = 0, ST1 = 1, ST2 = 2, ST3 = 3, ST4 = 4, ST5 = 5;
  reg [3:0] State, counter;
  
  always@(posedge clk)
  begin
    if(rst == 0)
    begin
      i <= 3'b000;
		idChecked <= 0;
		IDLED <= 0;
      ID <= 16'h0000;
      //passOut <= 0;
      State <=INITIAL;
    end
    else
    begin
      case(State)
      INITIAL:
      begin 
        pass_Adrs <= 0;
        idChecked <= 0;
		  IDLED <= 0;
        i <= 3'b000;
        ID <= 16'h0000;

        if(idOut == 1)
        begin
		    IDLED <= 1;
          ID[15:12] <= Out1;ID[11:8] <= Out2;ID[7:4] <= Out3;ID[3:0] <= Out4;
          State <= ST1;
        end
      end
      ST1:
      begin
        if(i < 5)
        begin
          i <= i+1;
          State <= ST2;
        end
      end
		ST2: 
		begin
		  State <= ST3;
		end
		ST3: 
		begin
		  State <= ST4;
		end
		
      ST4:
      begin
        if(ROM_ID == ID)
        begin
          i <= 0;
          pass_Adrs <= i;
          State <= ST5;
        end
        else
        begin
          State <= ST1;
        end
        /*pass_Adrs <= q; 
        idChecked <= 1;
        if(passOut == 1)
        begin
          State <= ST2;
        end*/
      end
      ST5:
      begin
        idChecked <= 1;
        if(passOut == 1)
        begin
          State <= INITIAL;
        end
      end
      
      endcase
    end
  end
endmodule