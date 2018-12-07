module Two_digit (clk, rst,ld_ip_1s, ld_ip_10s,one_sec_ip,DNB_ip_10s,four_bit_op_10s,four_bit_op_1s,DNB_op_1s,reconfig_bit);
input[3:0] ld_ip_1s, ld_ip_10s;
input one_sec_ip,DNB_ip_10s,reconfig_bit,clk,rst;
output[3:0] four_bit_op_10s,four_bit_op_1s;
output DNB_op_1s;
wire DNB_op_10s,ip_tenstimer,ip_100stimer;
Digit t5(clk,rst,one_sec_ip,DNB_op_10s,ld_ip_1s,reconfig_bit,DNB_op_1s,ip_tenstimer,four_bit_op_1s);
Digit t6(clk,rst,ip_tenstimer,DNB_ip_10s,ld_ip_10s,reconfig_bit,DNB_op_10s,ip_100stimer,four_bit_op_10s);
endmodule
