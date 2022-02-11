library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity easydriver_interface is
	port	(
			clk:			in std_logic;
			rst:			in std_logic;

			move_in:	in std_logic;
			dir_in:	in std_logic;

			m_pfd:		out std_logic;
			m_sleep:		out std_logic;
			m_enable:	out std_logic;
			m_ms1:		out std_logic;
			m_ms2:		out std_logic;
			m_dir:		out std_logic;
			m_step:		out std_logic
			);
end entity;

architecture easydriver_interface of easydriver_interface is
begin
	process(clk)
		variable m_step_r:		std_logic := '0'; -- movement pulse

		constant jog_max:			integer := 2**18;
		variable jog_dir_r:		std_logic := '0';
		variable jog_count:		integer range 0 to jog_max := 0;
		variable jog_count_p:	integer range 0 to jog_max := 0;
		variable jog_count_p2:	integer range 0 to 8 := 0;
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				jog_dir_r		:= '0';
				jog_count 		:= 0;
				jog_count_p 	:= 0;
			else
				if jog_count > 0 then
					jog_count := jog_count - 1;

					if jog_count_p/2 < jog_count then
						m_step_r := '1';
					elsif 0 < jog_count then
						m_step_r := '0';
					end if;
				else
					m_step_r := move_in;
					
					if move_in = '1' then
						if jog_count_p = 0 or jog_dir_r /= dir_in then
							jog_count_p := jog_max;
							jog_count_p2 := 0;
						else
							if jog_count_p > 512 and jog_count_p2 = 8 then
								jog_count_p := jog_count_p / 2;
								jog_count_p2 := 0;
							end if;
						end if;
						jog_count := jog_count_p;
						jog_count_p2 := jog_count_p2 + 1;
						
						jog_dir_r	:= dir_in;
					else
						jog_count_p := 0;
					end if;
				end if;
			end if;
		end if;

		m_pfd		<= '1';
		m_sleep	<= '1';
		m_enable <= '0';
		m_ms1		<= '1';
		m_ms2		<= '1';
		
		m_step <= m_step_r;
		m_dir <= jog_dir_r;
		
	end process;
end architecture;
