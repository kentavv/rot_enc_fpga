library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sig_gate is
	generic (cnt_max: integer := 1000000);
	port	(
			clk:	in std_logic;
			rst:	in std_logic;
			a:		in std_logic;
			z: 	out std_logic
			);
end entity;

architecture sig_gate of sig_gate is
begin
	process(clk)
		variable cnt: integer range 0 to cnt_max := 0;

	begin
		if rising_edge(clk) then
			if rst = '1' or a /= '1' then
				cnt := 0;
			end if;
			
			if cnt = cnt_max then
				z <= '1';
			else
				z <= '0';
				cnt := cnt + 1;
			end if;
		end if;
	end process;
end architecture;
