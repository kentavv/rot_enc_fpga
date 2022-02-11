library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tester is
	port	(
			clk:			in std_logic;
			rst:			in std_logic;

			dir:		out std_logic;
			step:		out std_logic
			);
end entity;

architecture tester of tester is
begin
	process(clk)
		variable count: integer range 0 to 1000000 := 0;
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				dir <= '0';
				step <= '0';
			else
				dir <= '0';
				
				if count = 0 then
					step <= '1';
				elsif count < 10 then
					step <= '1';
				else
					step <= '0';
				end if;
				
				if count = 1000000 then
					count := 0;
				else
					count := count + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
