module single_norm(clk, acc, div, sfp_in, sfp_out, norm_wr, div_q);

  parameter col = 8;
  parameter bw = 8;
  parameter bw_psum = 2*bw+4;

  input clk, acc, div;
  input [bw_psum*col-1:0] sfp_in;
  output [bw_psum*col-1:0] sfp_out;
  output reg [col-1:0] norm_wr; 
  output reg div_q;// 

  wire [col*bw_psum-1:0] abs;//
  reg fifo_wr;
  reg [bw_psum+3:0] sum_q;

  wire unsigned [col*bw_psum-1:0] sfp_in_sign;
  wire [bw_psum+3:0] sum_this_core;
  wire signed[bw_psum-1:0] sum_core;

 
  wire signed [bw_psum-1:0] sfp_in_sign0;
  wire signed [bw_psum-1:0] sfp_in_sign1;
  wire signed [bw_psum-1:0] sfp_in_sign2;
  wire signed [bw_psum-1:0] sfp_in_sign3;
  wire signed [bw_psum-1:0] sfp_in_sign4;
  wire signed [bw_psum-1:0] sfp_in_sign5;
  wire signed [bw_psum-1:0] sfp_in_sign6;
  wire signed [bw_psum-1:0] sfp_in_sign7;
 
  reg signed [bw_psum-1:0] sfp_out_sign0;
  reg signed [bw_psum-1:0] sfp_out_sign1;
  reg signed [bw_psum-1:0] sfp_out_sign2;
  reg signed [bw_psum-1:0] sfp_out_sign3;
  reg signed [bw_psum-1:0] sfp_out_sign4;
  reg signed [bw_psum-1:0] sfp_out_sign5;
  reg signed [bw_psum-1:0] sfp_out_sign6;
  reg signed [bw_psum-1:0] sfp_out_sign7;


  assign sfp_in_sign0 =  sfp_in_sign[bw_psum*1-1 : bw_psum*0];
  assign sfp_in_sign1 =  sfp_in_sign[bw_psum*2-1 : bw_psum*1];
  assign sfp_in_sign2 =  sfp_in_sign[bw_psum*3-1 : bw_psum*2];
  assign sfp_in_sign3 =  sfp_in_sign[bw_psum*4-1 : bw_psum*3];
  assign sfp_in_sign4 =  sfp_in_sign[bw_psum*5-1 : bw_psum*4];
  assign sfp_in_sign5 =  sfp_in_sign[bw_psum*6-1 : bw_psum*5];
  assign sfp_in_sign6 =  sfp_in_sign[bw_psum*7-1 : bw_psum*6];
  assign sfp_in_sign7 =  sfp_in_sign[bw_psum*8-1 : bw_psum*7];

  assign sfp_out[bw_psum*1-1 : bw_psum*0] = sfp_out_sign0;
  assign sfp_out[bw_psum*2-1 : bw_psum*1] = sfp_out_sign1;
  assign sfp_out[bw_psum*3-1 : bw_psum*2] = sfp_out_sign2;
  assign sfp_out[bw_psum*4-1 : bw_psum*3] = sfp_out_sign3;
  assign sfp_out[bw_psum*5-1 : bw_psum*4] = sfp_out_sign4;
  assign sfp_out[bw_psum*6-1 : bw_psum*5] = sfp_out_sign5;
  assign sfp_out[bw_psum*7-1 : bw_psum*6] = sfp_out_sign6;
  assign sfp_out[bw_psum*8-1 : bw_psum*7] = sfp_out_sign7;
  
  assign abs[bw_psum*1-1 : bw_psum*0] = (sfp_in[bw_psum*1-1]) ?  (~sfp_in[bw_psum*1-1 : bw_psum*0] + 1)  :  sfp_in[bw_psum*1-1 : bw_psum*0];
  assign abs[bw_psum*2-1 : bw_psum*1] = (sfp_in[bw_psum*2-1]) ?  (~sfp_in[bw_psum*2-1 : bw_psum*1] + 1)  :  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign abs[bw_psum*3-1 : bw_psum*2] = (sfp_in[bw_psum*3-1]) ?  (~sfp_in[bw_psum*3-1 : bw_psum*2] + 1)  :  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign abs[bw_psum*4-1 : bw_psum*3] = (sfp_in[bw_psum*4-1]) ?  (~sfp_in[bw_psum*4-1 : bw_psum*3] + 1)  :  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign abs[bw_psum*5-1 : bw_psum*4] = (sfp_in[bw_psum*5-1]) ?  (~sfp_in[bw_psum*5-1 : bw_psum*4] + 1)  :  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign abs[bw_psum*6-1 : bw_psum*5] = (sfp_in[bw_psum*6-1]) ?  (~sfp_in[bw_psum*6-1 : bw_psum*5] + 1)  :  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign abs[bw_psum*7-1 : bw_psum*6] = (sfp_in[bw_psum*7-1]) ?  (~sfp_in[bw_psum*7-1 : bw_psum*6] + 1)  :  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign abs[bw_psum*8-1 : bw_psum*7] = (sfp_in[bw_psum*8-1]) ?  (~sfp_in[bw_psum*8-1 : bw_psum*7] + 1)  :  sfp_in[bw_psum*8-1 : bw_psum*7];

  assign sum_core = {7'b0, sum_this_core[bw_psum+3:7]};

  fifo_depth16 #(.bw(bw_psum+4)) fifo_inst_int(
	  .rd_clk(clk),
	  .wr_clk(clk),
	  .in(sum_q),
	  .out(sum_this_core),
	  .rd(div),
	  .wr(fifo_wr),
	  .reset(reset)
  );
  
  fifo_depth16 #(.bw(bw_psum), .simd(col)) fifo_inst_norm (
	  .reset(reset),
	  .rd_clk(clk),
	  .wr_clk(clk),
	  .in(sfp_in),
	  .wr(acc),
	  .rd(div),
	  .out(sfp_in_sign)
  );



  always @ (posedge clk) begin
	  if (reset) begin
	    fifo_wr <= 0;
	  end
	  else begin
	    div_q <= div;
	    if (acc) begin

	      sum_q <=
		      {4'b0, abs[bw_psum*1-1 : bw_psum*0]} +
                      {4'b0, abs[bw_psum*2-1 : bw_psum*1]} +
           	      {4'b0, abs[bw_psum*3-1 : bw_psum*2]} +
           	      {4'b0, abs[bw_psum*4-1 : bw_psum*3]} +
            	      {4'b0, abs[bw_psum*5-1 : bw_psum*4]} +
           	      {4'b0, abs[bw_psum*6-1 : bw_psum*5]} +
           	      {4'b0, abs[bw_psum*7-1 : bw_psum*6]} +
                      {4'b0, abs[bw_psum*8-1 : bw_psum*7]} ;
	      fifo_wr <= 1;
	     end
	     else begin
	       fifo_wr <= 0;

	       if (div) begin
		 sfp_out_sign0 <= sfp_in_sign0 / sum_core;
           	 sfp_out_sign1 <= sfp_in_sign1 / sum_core;
           	 sfp_out_sign2 <= sfp_in_sign2 / sum_core;
          	 sfp_out_sign3 <= sfp_in_sign3 / sum_core;
          	 sfp_out_sign4 <= sfp_in_sign4 / sum_core;
        	 sfp_out_sign5 <= sfp_in_sign5 / sum_core;
           	 sfp_out_sign6 <= sfp_in_sign6 / sum_core;
           	 sfp_out_sign7 <= sfp_in_sign7 / sum_core;
	         norm_wr <= {(col){1'b1}};
	       end
	       else begin
		 norm_wr <= {(col){1'b0}};
	       end
	     end
	   end
  end
endmodule

