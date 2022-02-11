library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tachometer_pulse is
	generic (clock_period: integer := 1000000);
	port	(
			clk:			in std_logic;
			rst:			in std_logic;
			step:			in std_logic;
			dir:			in std_logic;
			rpm:			out std_logic_vector(15 downto 0) -- 2^16 = 65,536, or enough space for 6553.6 rpm
			);
end entity;

architecture tachometer_pulse of tachometer_pulse is
begin
	process(clk)
		variable step_r:		std_logic := '0'; -- the direction of the last pulse
		variable dir_r:		std_logic := '0'; -- the direction since the last home
		type count_buf_t is array (1 to 60) of integer range 0 to 600000;
		variable count_buf: count_buf_t;
		variable count: integer range 0 to clock_period := 0;
		variable sum: 		integer range 0 to 36000000 := 0;
		variable avg_rps: integer range 0 to 6000000 := 0;
		variable avg_rpm: integer range 0 to 6000 := 0;
		variable i: integer range 1 to 60;
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				step_r		:= '0';
				dir_r			:= '0';
				for i in 1 to 60 loop
					count_buf(i) := 0;
				end loop;
				count := 0;
			else
				step_r := step;
				
				if step_r = '1' then
					count_buf(1) := count_buf(1) + 1;
				end if;
				if count = clock_period then
					count := 0;
					for i in 1 to 59 loop	
						count_buf(i+1) := count_buf(i);
					end loop;
					count_buf(1) := 0;
				else 
					count := count + 1;
				end if;
			end if;
			
			sum := count_buf(1);
			for i in 2 to 60 loop	
				sum := sum + count_buf(i);
			end loop;
			avg_rps := (sum * 10) / (10000 * 60);
			avg_rpm := (sum * 10) / 10000;
		end if;
	 
		rpm	<= std_logic_vector(to_unsigned(avg_rpm, rpm'length));
		
	end process;
end architecture;
