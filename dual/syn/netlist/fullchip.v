// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_core0, clk_core1, mem_in_core0, mem_in_core1, out_core0, out_core1, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk_core0, clk_core1; 
input  [pr*bw-1:0] mem_in_core0;
input  [pr*bw-1:0] mem_in_core1;
output [bw_psum*col-1:0] out_core0;
output [bw_psum*col-1:0] out_core1;
input  [19:0] inst; 
input  reset;

wire [bw_psum+3:0] sum_in_core0;
wire [bw_psum+3:0] sum_in_core1;
wire [bw_psum+3:0] sum_out_core0;
wire [bw_psum+3:0] sum_out_core1;
wire [bw_psum+3:0] fifo_out_0;
wire [bw_psum+3:0] fifo_out_1;

assign sum_in_core0 = fifo_out_1;
assign sum_in_core1 = fifo_out_0;



core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance0 (
      .reset(reset), 
      .clk(clk_core0),
      .sum_in(sum_in_core0),
      .sum_out(sum_out_core0), 
      .mem_in(mem_in_core0),
      .out(out_core0), 
      .inst(inst)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .reset(reset),
      .clk(clk_core1),
      .sum_in(sum_in_core1),
      .sum_out(sum_out_core1),
      .mem_in(mem_in_core1),
      .out(out_core1),
      .inst(inst)
);

fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core0 (
        .reset(reset),
	.rd_clk(clk_core1),
	.wr_clk(clk_core0),
	.in(sum_out_core0),
	.out(fifo_out_0),
	.rd(inst[18]),
	.wr(inst[19])
);


fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core1 (
        .reset(reset),
	.rd_clk(clk_core0),
	.wr_clk(clk_core1),
	.in(sum_out_core1),
	.out(fifo_out_1),
	.rd(inst[18]),
	.wr(inst[19])
);




endmodule
