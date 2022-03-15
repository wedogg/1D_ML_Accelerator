// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 16;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  K_core0[col-1:0][pr-1:0];
integer  K_core1[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result_core0[total_cycle-1:0][col-1:0];
integer  result_core1[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];
integer  division_core0[total_cycle-1:0][col-1:0];//
integer  division_core1[total_cycle-1:0][col-1:0];//

integer i,j,k,t,p,q,s,u, m;





reg reset = 1;
reg clk = 0;
reg clk_core0 = 0;
reg clk_core1 = 0;
reg [pr*bw-1:0] mem_in_core0; 
reg [pr*bw-1:0] mem_in_core1; 
reg start_core0, start_core1;



reg [bw_psum-1:0] temp5b;
reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b;


fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk_core0(clk),
      .clk_core1(clk),
      .mem_in_core0(mem_in_core0), 
      .mem_in_core1(mem_in_core1), 
      .start_core0(start_core0),
      .start_core1(start_core1)
);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          $display("%d\n", Q[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// K data txt reading /////

$display("##### K_core0 data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K_core0[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////


///// K data txt reading /////

$display("##### K_core0 data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K_core1[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////








/////////////// Estimated result printing /////////////////


$display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result_core0[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result_core0[t][q] = result_core0[t][q] + Q[t][k] * K_core0[q][k];
         end

         temp5b = result_core0[t][q];
         temp16b = {temp16b[139:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %40h", t, temp16b);
  end

//////////////////////////////////////////////

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result_core1[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result_core1[t][q] = result_core1[t][q] + Q[t][k] * K_core1[q][k];
         end

         temp5b = result_core1[t][q];
         temp16b = {temp16b[139:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %40h", t, temp16b);
  end


//////////////////////////////////////////////



$display("############### Sum ###############");



  for (t=0; t<total_cycle; t=t+1) begin
      sum[t] = 0;
  end    
  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
      if (result_core0[t][q] >= 0) begin
	if (result_core1[t][q] >= 0) sum[t] = sum[t] + result_core0[t][q] + result_core1[t][q];//
	else sum[t] = sum[t] + result_core0[t][q] - result_core1[t][q];
      end
      
      else begin
	if (result_core1[t][q] >=0) sum[t] = sum[t] - result_core0[t][q] + result_core1[t][q];
	else sum[t] = sum[t] -result_core0[t][q] - result_core1[t][q];
      end
    end
    
    temp_sum = sum[t]; 
    $display("prd @cycle%2d: %7h", t, temp_sum);
  end




  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
      division_core0[t][q] = result_core0[t][q] * 128 / (sum[t]);

      temp5b = division_core0[t][q];
      temp16b = {temp16b[139:0], temp5b};
    end

    $display("prd @cycle%2d: %40h", t, temp16b);
  end

  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
      division_core1[t][q] = result_core1[t][q] * 128 / (sum[t]);

      temp5b = division_core1[t][q];
      temp16b = {temp16b[139:0], temp5b};
    end

    $display("prd @cycle%2d: %40h", t, temp16b);
  end


///// Qmem writing  /////


$display("##### Qmem writing  #####");


  #0.5 clk = 1'b0;
  reset = 0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  start_core0 = 1;
  #0.5 clk = 1'b1; 

  for (q=0; q<total_cycle; q=q+1) begin
  
    #0.5 clk = 1'b0;
    mem_in_core0[1*bw-1:0*bw] = Q[q][0];
    mem_in_core0[2*bw-1:1*bw] = Q[q][1];
    mem_in_core0[3*bw-1:2*bw] = Q[q][2];
    mem_in_core0[4*bw-1:3*bw] = Q[q][3];
    mem_in_core0[5*bw-1:4*bw] = Q[q][4];
    mem_in_core0[6*bw-1:5*bw] = Q[q][5];
    mem_in_core0[7*bw-1:6*bw] = Q[q][6];
    mem_in_core0[8*bw-1:7*bw] = Q[q][7];
    mem_in_core0[9*bw-1:8*bw] = Q[q][8];
    mem_in_core0[10*bw-1:9*bw] = Q[q][9];
    mem_in_core0[11*bw-1:10*bw] = Q[q][10];
    mem_in_core0[12*bw-1:11*bw] = Q[q][11];
    mem_in_core0[13*bw-1:12*bw] = Q[q][12];
    mem_in_core0[14*bw-1:13*bw] = Q[q][13];
    mem_in_core0[15*bw-1:14*bw] = Q[q][14];
    mem_in_core0[16*bw-1:15*bw] = Q[q][15];
    
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  start_core1 = 1;
  #0.5 clk = 1'b1;



///// Kmem writing  /////

$display("##### Kmem writing #####");



  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;
    mem_in_core1[1*bw-1:0*bw] = Q[q][0];
    mem_in_core1[2*bw-1:1*bw] = Q[q][1];
    mem_in_core1[3*bw-1:2*bw] = Q[q][2];
    mem_in_core1[4*bw-1:3*bw] = Q[q][3];
    mem_in_core1[5*bw-1:4*bw] = Q[q][4];
    mem_in_core1[6*bw-1:5*bw] = Q[q][5];
    mem_in_core1[7*bw-1:6*bw] = Q[q][6];
    mem_in_core1[8*bw-1:7*bw] = Q[q][7];
    mem_in_core1[9*bw-1:8*bw] = Q[q][8];
    mem_in_core1[10*bw-1:9*bw] = Q[q][9];
    mem_in_core1[11*bw-1:10*bw] = Q[q][10];
    mem_in_core1[12*bw-1:11*bw] = Q[q][11];
    mem_in_core1[13*bw-1:12*bw] = Q[q][12];
    mem_in_core1[14*bw-1:13*bw] = Q[q][13];
    mem_in_core1[15*bw-1:14*bw] = Q[q][14];
    mem_in_core1[16*bw-1:15*bw] = Q[q][15];
    if (q<col) begin
    mem_in_core0[1*bw-1:0*bw] = K_core0[q][0];
    mem_in_core0[2*bw-1:1*bw] = K_core0[q][1];
    mem_in_core0[3*bw-1:2*bw] = K_core0[q][2];
    mem_in_core0[4*bw-1:3*bw] = K_core0[q][3];
    mem_in_core0[5*bw-1:4*bw] = K_core0[q][4];
    mem_in_core0[6*bw-1:5*bw] = K_core0[q][5];
    mem_in_core0[7*bw-1:6*bw] = K_core0[q][6];
    mem_in_core0[8*bw-1:7*bw] = K_core0[q][7];
    mem_in_core0[9*bw-1:8*bw] = K_core0[q][8];
    mem_in_core0[10*bw-1:9*bw] = K_core0[q][9];
    mem_in_core0[11*bw-1:10*bw] = K_core0[q][10];
    mem_in_core0[12*bw-1:11*bw] = K_core0[q][11];
    mem_in_core0[13*bw-1:12*bw] = K_core0[q][12];
    mem_in_core0[14*bw-1:13*bw] = K_core0[q][13];
    mem_in_core0[15*bw-1:14*bw] = K_core0[q][14];
    mem_in_core0[16*bw-1:15*bw] = K_core0[q][15];
    end
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;
///////////////////////////////////////////

  
  for (q=0; q<col; q=q+1) begin
    #0.5 clk = 1'b0;
    mem_in_core1[1*bw-1:0*bw] = K_core1[q][0];
    mem_in_core1[2*bw-1:1*bw] = K_core1[q][1];
    mem_in_core1[3*bw-1:2*bw] = K_core1[q][2];
    mem_in_core1[4*bw-1:3*bw] = K_core1[q][3];
    mem_in_core1[5*bw-1:4*bw] = K_core1[q][4];
    mem_in_core1[6*bw-1:5*bw] = K_core1[q][5];
    mem_in_core1[7*bw-1:6*bw] = K_core1[q][6];
    mem_in_core1[8*bw-1:7*bw] = K_core1[q][7];
    mem_in_core1[9*bw-1:8*bw] = K_core1[q][8];
    mem_in_core1[10*bw-1:9*bw] = K_core1[q][9];
    mem_in_core1[11*bw-1:10*bw] = K_core1[q][10];
    mem_in_core1[12*bw-1:11*bw] = K_core1[q][11];
    mem_in_core1[13*bw-1:12*bw] = K_core1[q][12];
    mem_in_core1[14*bw-1:13*bw] = K_core1[q][13];
    mem_in_core1[15*bw-1:14*bw] = K_core1[q][14];
    mem_in_core1[16*bw-1:15*bw] = K_core1[q][15];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;



  for (q=0; q<150; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;

  end


#10 $finish;


end

endmodule




