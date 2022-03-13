

set clock_cycle 2.0
set io_delay 0.2

set clock_port_core0 clk_core0
set clock_port_core1 clk_core1

create_clock -name clk_core0 -period $clock_cycle [get_ports $clock_port_core0]
create_clock -name clk_core1 -period $clock_cycle [get_ports $clock_port_core1]

set_input_delay -clock [get_ports $clock_port_core0] -add_delay -max $io_delay [all_inputs]
set_output_delay -clock [get_ports $clock_port_core0] -add_delay -max $io_delay [all_outputs]

set_input_delay -clock [get_ports $clock_port_core1] -add_delay -max $io_delay [all_inputs]
set_output_delay -clock [get_ports $clock_port_core1] -add_delay -max $io_delay [all_outputs]

set_false_path -from clk_core0 -to clk_core1
