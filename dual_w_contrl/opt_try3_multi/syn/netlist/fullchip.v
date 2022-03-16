// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_core0, clk_core1, mem_in_core0, mem_in_core1, out_core0, out_core1, start_core0, start_core1, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk_core0, clk_core1, start_core0, start_core1; 
input  [pr*bw-1:0] mem_in_core0;
input  [pr*bw-1:0] mem_in_core1;
output [bw_psum*col-1:0] out_core0;
output [bw_psum*col-1:0] out_core1;
input  reset;

wire [bw_psum+3:0] sum_in_core0;
wire [bw_psum+3:0] sum_in_core1;
wire [bw_psum+3:0] sum_out_core0;
wire [bw_psum+3:0] sum_out_core1;
wire [bw_psum+3:0] fifo_out_0;
wire [bw_psum+3:0] fifo_out_1;
wire fifo_ext_rd_core0, fifo_ext_rd_core1;
wire div_core0, div_core1;
wire empty_core0, empty_core1;
wire ready_core0, ready_core1;

assign ready_core0 = !empty_core1;
assign ready_core1 = !empty_core0;

assign sum_in_core0 = fifo_out_1;
assign sum_in_core1 = fifo_out_0;


controller #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) controller_instance0 (
	.reset(reset),
	.clk(clk_core0),
	.mem_in(mem_in_core0),
	.start(start_core0),
	.out(out_core0),
	.sum_in(sum_in_core0),
	.sum_out(sum_out_core0),
	.fifo_ext_rd(fifo_ext_rd_core0),
	.fifo_in_ready(ready_core0),
	.div_o(div_core0)
);



controller #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) controller_instance1 (
	.reset(reset),
	.clk(clk_core1),
	.mem_in(mem_in_core1),
	.start(start_core1),
	.out(out_core1),
	.sum_in(sum_in_core1),
	.sum_out(sum_out_core1),
	.fifo_ext_rd(fifo_ext_rd_core1),
	.fifo_in_ready(ready_core1),
	.div_o(div_core1)
);


fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core0 (
        .reset(reset),
	.rd_clk(clk_core1),
	.wr_clk(clk_core0),
	.in(sum_out_core0),
	.out(fifo_out_0),
	.rd(div_core1),
	.wr(fifo_ext_rd_core0),
	.o_empty(empty_core0)
);


fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core1 (
        .reset(reset),
	.rd_clk(clk_core0),
	.wr_clk(clk_core1),
	.in(sum_out_core1),
	.out(fifo_out_1),
	.rd(div_core0),
	.wr(fifo_ext_rd_core1),
	.o_empty(empty_core1)
);




endmodule
