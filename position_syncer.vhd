library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity position_syncer IS
	generic (position_max: integer := 2500 * 4);
	port	(
			clk:			in std_logic;
			rst:			in std_logic;

			e_position:	in std_logic_vector(13 downto 0);
			e_dir_in:	in std_logic;

			m_position:	out std_logic_vector(13 downto 0);
			shortest_path:	out std_logic
			);
end entity;

architecture position_syncer of position_syncer is
begin
	process(clk)
		variable e_pos_r:			integer range 0 to position_max := 0;
		--variable e_dir_in_r:		std_logic := '0'; -- the direction of the last pulse

		variable pe_pos_r:			integer range 0 to position_max := 0; -- previous position
		--variable pe_dir_in_r:		std_logic := '0'; -- the direction of the last pulse

		variable m_pos_r:			integer range 0 to position_max := 0;
		variable shortest_path_r:		std_logic := '0'; -- take the shortest path to get to the destination
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				e_pos_r			:= 0;
				--e_dir_in_r		:= '0';

				m_pos_r			:= 0;
				shortest_path_r		:= '0';				
			else
				e_pos_r			:= to_integer(unsigned(e_position));
				--e_dir_in_r		:= e_dir_in;

				if e_pos_r /= pe_pos_r then
					--m_pos_r := e_pos_r * 2;
					m_pos_r := e_pos_r;
					shortest_path_r := '1';
				end if;
				
				pe_pos_r := e_pos_r;
				--pe_dir_in_r := e_dir_in_r;				
			end if;
		end if;

		m_position	<= std_logic_vector(to_unsigned(m_pos_r, m_position'length));
		shortest_path	<= shortest_path_r;
		
	end process;
end architecture;
