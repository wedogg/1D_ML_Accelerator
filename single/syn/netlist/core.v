// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, mem_in, out, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

output  reg [bw_psum*col-1:0] out;
output  reg [bw_psum+3:0] sum_out;
wire   [bw_psum+3:0] sum;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [18:0] inst;//instructs
input  reset;
wire [bw_psum*col-1:0] sfp_in;//single_norm input

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] ofifo_in;//ofifo input array_out or sfp_out 
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;//single_norm output
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  [col-1:0] array_wr;// array_mac wirite
wire  [col-1:0] norm_wr;// single_norm write
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 

wire div_q;//lateched div signal

assign div = inst[18];//div instruct
assign acc = inst[17];//acc instruct
assign ofifo_rd = inst[16];
assign qkmem_add = inst[15:12];
assign pmem_add = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = fifo_out;
assign sfp_in = pmem_out;
assign ofifo_in = div_q ? sfp_out : array_out;//
assign fifo_wr = div_q ? norm_wr : array_wr; //

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(array_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(ofifo_in),//
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);

single_norm #(.bw(bw)) single_norm_inst(
	.clk(clk),
	.acc(acc),
	.div(div),
        .sum_out(sum),
	.sfp_in(sfp_in),
	.sfp_out(sfp_out),
	.norm_wr(norm_wr),
	.div_q(div_q)
);

sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);



  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      out <= pmem_out;
      sum_out <= sum;
      if(pmem_wr)
         $display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
