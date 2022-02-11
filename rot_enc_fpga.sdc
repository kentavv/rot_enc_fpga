create_clock -period 20.000 -name CLOCK_50 [get_ports CLOCK_50]
derive_pll_clocks
derive_clock_uncertainty

create_clock -period 1000 -name virt_clk_in0
create_clock -period 1000 -name virt_clk_in1

set_input_delay -clock virt_clk_in0 -min 0 [get_ports GPIO_00]
set_input_delay -clock virt_clk_in0 -max 1 [get_ports GPIO_00]
set_input_delay -clock virt_clk_in1 -min 0 [get_ports GPIO_01]
set_input_delay -clock virt_clk_in1 -max 1 [get_ports GPIO_01]
