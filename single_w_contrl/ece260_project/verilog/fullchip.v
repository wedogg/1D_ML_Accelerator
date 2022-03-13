// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, mem_in, reset, start, out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk; 
input  [pr*bw-1:0] mem_in;  
input  reset;
input  start;
output [bw_psum*col-1:0]out;

controller #(.bw(bw)) controller_inst(
	.clk(clk),
	.reset(reset),
	.start(start),
	.mem_in(mem_in),
	.out(out)
);



endmodule
