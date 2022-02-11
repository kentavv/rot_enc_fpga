library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_controller IS
	generic (position_max: integer := 2500 * 4);
	port	(
			clk:			in std_logic;
			rst:			in std_logic;

			desired_position:	in std_logic_vector(13 downto 0);
			current_position:	in std_logic_vector(13 downto 0);

			jog_left:	in std_logic;
			jog_right:	in std_logic;

			dir:				in std_logic; -- 0=reverse, 1=forward
			shortest_path:	in std_logic; -- 0=move in direction of dir, 1=move in dir of shortest path

			mode:	in std_logic; -- 0=jog, 1=go to desired position

			m_move:		out std_logic;
			m_dir:		out std_logic;
			
			pos_error:	out std_logic_vector(14 downto 0)
			);
end entity;

architecture stepper_controller of stepper_controller is
begin
	process(clk)
		variable desired_pos_r:			integer range 0 to position_max := 0;
		variable current_pos_r:			integer range 0 to position_max := 0;

		variable dir_r:			std_logic := '0'; -- the direction of the last pulse
		variable step_r:			std_logic := '0'; -- movement pulse

		variable pos_error_r:	integer range 0 to position_max*2 := 0;
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				desired_pos_r			:= 0;
				current_pos_r			:= 0;
				
				step_r			:= '0';
				dir_r				:= '0';
			else
				step_r		:= '0';
				dir_r			:= '0';
				
				if mode = '0' then
					step_r	:= jog_left xor jog_right;
					dir_r 	:= jog_right;
				else
					desired_pos_r	:= to_integer(unsigned(desired_position));
					current_pos_r	:= to_integer(unsigned(current_position));

					step_r	:= '0';
					dir_r 	:= '0';

					if desired_pos_r = current_pos_r then
						step_r		:= '0';
						dir_r			:= '0';

						pos_error_r	:= 0;
					else
						step_r		:= '1';

						if shortest_path = '1' then
							if desired_pos_r < current_pos_r then
								dir_r			:= '0';
								pos_error_r 	:= current_pos_r - desired_pos_r;
							elsif desired_pos_r > current_pos_r then
								dir_r			:= '1';
								pos_error_r 	:= desired_pos_r - current_pos_r;
							end if;
						else
							dir_r := dir;
							if dir = '0' then
								if desired_pos_r < current_pos_r then
									pos_error_r 	:= current_pos_r - desired_pos_r;
								else
									pos_error_r 	:= current_pos_r + (position_max - desired_pos_r);
								end if;
							else
								if desired_pos_r > current_pos_r then
									pos_error_r 	:= desired_pos_r - current_pos_r;
								else
									pos_error_r 	:= desired_pos_r + (position_max - current_pos_r);
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;

		m_move	<= step_r;
		m_dir		<= dir_r;
		
		pos_error <= std_logic_vector(to_unsigned(pos_error_r, pos_error'length));
		
	end process;
end architecture;
