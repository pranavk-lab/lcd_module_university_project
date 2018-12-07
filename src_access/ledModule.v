// ECE6370
// Author: Praneeth Reddy Mosali, PeopleSoft ID: 1638989
// Led Module.
// This is used to turn on the LEDs that is Red and Green LED if the given input matches binary number
// 1111 (F in Hexa decimal and 15 in decimal).


module ledModule(ledIn, ledGreen, ledRed);	
  input [3:0] ledIn;
  output ledGreen, ledRed;
  reg ledGreen, ledRed;

  always @ (ledIn)
  begin
    if(ledIn == 4'b1111)
      begin
	ledGreen  = 1;
	ledRed = 0;
      end
    else
      begin
	ledGreen  = 0;
	ledRed = 1;
      end
  end

endmodule
 