module controller (clk, reset, mem_in, start, out, sum_in, sum_out, fifo_ext_rd, fifo_in_ready, div_o);

  parameter bw = 8;
  parameter bw_psum = 2*bw+4;
  parameter col = 8;
  parameter pr = 16;
  parameter total_cycle = 16;

  input clk, start, reset;
  input [pr*bw-1:0] mem_in;
  output [bw_psum*col-1:0] out;
  input  [bw_psum+3:0] sum_in;
  output [bw_psum+3:0] sum_out;
  output reg fifo_ext_rd;
  output reg div_o;
  input fifo_in_ready;


  wire [19:0] inst;
  reg div;
  reg acc;
  reg ofifo_rd;
  reg qmem_rd;
  reg qmem_wr; 
  reg kmem_rd; 
  reg kmem_wr;
  reg pmem_rd; 
  reg pmem_wr; 
  reg execute;
  reg load;
  reg [3:0] qkmem_add;
  reg [3:0] pmem_add;

  reg [4:0] cnt;
  reg load_times;
  reg wr_times;


  assign inst[19] = fifo_ext_rd;
  assign inst[18] = div;
  assign inst[17] = acc;
  assign inst[16] = ofifo_rd;
  assign inst[15:12] = qkmem_add;
  assign inst[11:8]  = pmem_add;
  assign inst[7] = execute;
  assign inst[6] = load;
  assign inst[5] = qmem_rd;
  assign inst[4] = qmem_wr;
  assign inst[3] = kmem_rd;
  assign inst[2] = kmem_wr;
  assign inst[1] = pmem_rd;
  assign inst[0] = pmem_wr;



  parameter READY=4'b0000, Q_WR=4'b0001, K_WR=4'b0010, LOADING=4'b0011,EXECUTE=4'b0100, WR_TO_MEM=4'b0101, FETCH=4'b0110, NORM=4'b0111, LOAD=4'b1000, FIFO_SUM=4'b1001, WAIT=4'b1010;
  
  reg [3:0] state;


  core #(.bw(bw), .col(col), .pr(pr)) core_inst (
	  .reset(reset),
	  .clk(clk),
	  .inst(inst),
	  .mem_in(mem_in),
	  .out(out),
	  .sum_in(sum_in),
	  .sum_out(sum_out)

  );


  always @ (negedge clk) begin
    if (reset) begin
      div <= 0;
      acc <= 0;
      ofifo_rd <= 0;
      qmem_rd <= 0;
      qmem_wr <= 0; 
      kmem_rd <= 0; 
      kmem_wr <= 0;
      pmem_rd <= 0; 
      pmem_wr <= 0; 
      execute <= 0;
      load <= 0;
      qkmem_add <= 0;
      pmem_add <= 0;

      cnt <= 0;
      load_times <= 0;
      wr_times <= 0;
      state <= READY;
    end
    else begin
    case(state)
      
    READY:
	    if (start==1) begin
	      state <= Q_WR; 
            end
    Q_WR:
	    if (cnt == total_cycle) begin
	      qmem_wr <= 0;
	      qkmem_add <= 0;
	      state <= K_WR;
	      cnt <= 0;
	    end
	    else begin
	      if (cnt > 0) begin 
                qkmem_add <= qkmem_add + 1;
	      end
	      if (cnt == 0) qmem_wr <= 1;
	      cnt <= cnt + 1;
            end
    K_WR:
	    if (cnt == col) begin
	      cnt <= 0;
	      state <= LOADING;
	      kmem_wr <= 0;
	      qkmem_add <= 0;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) kmem_wr <= 1;
	      else begin
	        qkmem_add <= qkmem_add + 1;
	      end
            end
    LOADING:
	    if (cnt == col+2) begin
	      load <= 0;
	      cnt <= 0;
	      state <= LOAD;
            end
	    else if (cnt == col+1) begin
	      kmem_rd <= 0;
	      qkmem_add <= 0;
	      cnt <= cnt + 1;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) load <= 1;
	      else if (cnt == 1) kmem_rd <= 1;
	      else qkmem_add <= qkmem_add + 1;
	    end

    LOAD:
	    if (cnt == 9) begin
              if (load_times == 0) begin 
		state <= EXECUTE;
	        cnt <= 0;
	        load_times <= load_times + 1;
	      end
	      else begin
                load_times <= 0;
		state <= WR_TO_MEM;
		cnt <= 0;
	      end
	    end
	    else cnt <= cnt + 1;
    EXECUTE:
	    if (cnt == total_cycle+1) begin//cnt==total_cycle
	      qmem_rd <= 0;
	      qkmem_add <= 0;
	      execute <= 0;
	      cnt <= 0;
	      state <= LOAD;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
	        execute <= 1;
		qmem_rd <= 1;
	      end
	      else qkmem_add <= qkmem_add + 1;
	    end
    WR_TO_MEM:
	    if (cnt == total_cycle) begin
	      pmem_wr <= 0;
	      pmem_add <= 0;
	      ofifo_rd <= 0;
	      cnt <=0;
	      if (wr_times == 0) begin 
		state <= FETCH;
		wr_times <= wr_times + 1;
              end
	      else begin
		state <= READY;
		wr_times <= 0;
              end
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
		ofifo_rd <= 1;
		pmem_wr <= 1;
              end
	      else pmem_add <= pmem_add + 1;
	    end
    FETCH:
	    if (cnt == total_cycle + 1) begin
	      acc <= 0;
	      cnt <= 0;
	      state <= FIFO_SUM;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == total_cycle) begin
	        pmem_rd <= 0;
	        pmem_add <= 0;
	      end
	      else begin
	        if (cnt == 0) pmem_rd <= 1;
		else begin
	          pmem_add <= pmem_add + 1;
		  if (cnt == 1) acc <= 1;
		end
	      end
            end
    FIFO_SUM:
	    if (cnt == total_cycle) begin
              fifo_ext_rd <= 0;
	      cnt <= 0;
	      state <= WAIT;
            end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) fifo_ext_rd <= 1;
	    end
    WAIT:
	    if (fifo_in_ready) state <= NORM;
    NORM:
	    if (cnt == total_cycle) begin
	      div <= 0;
	      div_o <= 0;
              cnt <= 0;
	      state <= WR_TO_MEM;
            end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
	        div <= 1;
		div_o <= 1;
              end
	    end
    endcase
  end
end


endmodule
