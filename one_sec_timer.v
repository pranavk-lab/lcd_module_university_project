module one_sec_timer(clk, rst, enable, one_sec_time_out);
input clk, rst, enable;
output one_sec_time_out;
wire one_ms_time_out, ten_ms_time_out, hund_ms_time_out;
	one_ms_timer t1(clk, rst, enable, one_ms_time_out);
	counter counter1(clk, rst, one_ms_time_out, ten_ms_time_out);
	counter counter5(clk, rst, ten_ms_time_out, hund_ms_time_out);
	counter counter6(clk, rst, hund_ms_time_out, one_sec_time_out);
endmodule
