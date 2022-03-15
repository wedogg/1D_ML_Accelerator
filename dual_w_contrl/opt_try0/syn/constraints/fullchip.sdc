

set clock_cycle 1.0
set io_delay 0.2

set clock_port_core0 clk_core0
set clock_port_core1 clk_core1

create_clock -name clk_core0 -period $clock_cycle [get_ports $clock_port_core0]
create_clock -name clk_core1 -period $clock_cycle [get_ports $clock_port_core1]

set_false_path -from clk_core0 -to clk_core1

set_multicycle_path -setup 3 -from fifo_depth16_inst_core1/rd_ptr_reg_0_ -to controller_instance0/core_inst/sfp_row_inst/sfp_out_sign[*]
set_multicycle_path -hold 2 -from fifo_depth16_inst_core1/rd_ptr_reg_0_ -to controller_instance0/core_inst/sfp_row_inst/sfp_out_sign[*]


set_multicycle_path -setup 3 -from controller_instance0/core_inst/sfp_row_inst/ofifo_instance_sfp/col_idx_5__fifo_instance/rd_ptr_reg[*] -to controller_instance0/core_inst/sfp_row_inst/sfp_out_sign[*]
set_multicycle_path -hold 2 -from controller_instance0/core_inst/sfp_row_inst/ofifo_instance_sfp/col_idx_5__fifo_instance/rd_ptr_reg[*] -to controller_instance0/core_inst/sfp_row_inst/sfp_out_sign[*]

set_multicycle_path -setup 3 -from fifo_depth16_inst_core0/rd_ptr_reg_0_ -to controller_instance1/core_inst/sfp_row_inst/sfp_out_sign[*]
set_multicycle_path -hold 2 -from fifo_depth16_inst_core0/rd_ptr_reg_0_ -to controller_instance1/core_inst/sfp_row_inst/sfp_out_sign[*]

set_multicycle_path -setup 3 -from controller_instance1/core_inst/sfp_row_inst/ofifo_instance_sfp/col_idx_5__fifo_instance/rd_ptr_reg[*] -to controller_instance1/core_inst/sfp_row_inst/sfp_out_sign[*]
set_multicycle_path -hold 2 -from controller_instance1/core_inst/sfp_row_inst/ofifo_instance_sfp/col_idx_5__fifo_instance/rd_ptr_reg[*] -to controller_instance1/core_inst/sfp_row_inst/sfp_out_sign[*]

