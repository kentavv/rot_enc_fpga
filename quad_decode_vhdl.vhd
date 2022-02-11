library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quad_decode_vhdl IS
	generic (position_max: integer := 2500 * 4;
				use_home: std_logic := '1');
	port	(
			clk:			in std_logic;
			a:				in std_logic;
			b:				in std_logic;
			z:				in std_logic;
			arst:			in std_logic;
			position:	out std_logic_vector(13 downto 0);
			dir:			out std_logic;
			overflow:	out std_logic;
			homed:		out std_logic;
			step:			out std_logic;
			dirr:			out std_logic;
			err:			out std_logic
			);
end entity;

architecture quad_decode_vhdl of quad_decode_vhdl is
begin
	process(clk)
		variable pos_r:		integer range 0 to position_max := 0;
		variable a_r: 			std_logic_vector(1 downto 0) := "00";
		variable b_r:			std_logic_vector(1 downto 0) := "00";
		 
		variable dir_r:		std_logic := '0'; -- the direction of the last pulse
		variable dir_r2:		std_logic := '0'; -- the direction since the last home
		variable p_r:			std_logic := '0'; -- movement pulse
		variable overflow_r: std_logic := '0'; -- overflow or underflow flag, cleared when next homed or rst asserted
		variable homed_r: 	std_logic := '0'; -- has home been located?
		variable err_r: 		std_logic := '0'; -- decode error?
	begin 
--    IF(arst = '1') THEN
--	   pos_r			:= 0;
--	   overflow_r	:= '0';
--	   homed_r		:= '0';
--		
--		a_r := "00";
--		b_r := "00";
--	 ELS
		if rising_edge(clk) then
			if arst = '1' then
				pos_r			:= 0;
				homed_r		:= not use_home;
				--a_r			:= "00";
				--b_r			:= "00";

				--dir_r		:= '0';
				p_r			:= '0';
				overflow_r	:= '0';
				err_r 		:= '0';
			else
				a_r 	:= a_r(0) & a;
				b_r 	:= b_r(0) & b;
				err_r := '0';
				
				if a_r = "01" then
					p_r := '1';
					--if b = '0' then dir_r := '1' else dir_r := '0';
					dir_r := not b;
				elsif a_r = "10" then
					p_r := '1';
					--if b = '1' then dir_r := '1' else dir_r := '0';
					dir_r := b;
				elsif b_r = "01" then
					p_r := '1';
					--if a = '1' then dir_r := '1' else dir_r := '0';
					dir_r := a;
				elsif b_r = "10" then
					p_r := '1';
					--if a = '0' then dir_r := '1' else dir_r := '0';
					dir_r := not a;
				else
					p_r := '0';
					err_r := '1';
				end if;
					
				if(z='1' and a='0' and b='0') then
					if dir_r = '1' then
						pos_r := 0;
					else
					  pos_r := position_max;
					end if;
					dir_r2		:= dir_r;
					overflow_r	:= '0';
					homed_r		:= '1';
				elsif homed_r ='1' and p_r = '1' then
					if dir_r = '1' then
						--overflow_r := overflow_r or (pos_r = 2499);
						if pos_r < position_max then
							pos_r := pos_r + 1;
						else
							overflow_r := '1';
						end if;
					elsif dir_r = '0' then 
						--overflow_r := overflow_r or pos_r = 0;
						if pos_r > 0 then
							pos_r := pos_r - 1;
						else
							overflow_r := '1';
						end if;
					end if;
				end if;
			end if;
		end if;
	 
		position	<= std_logic_vector(to_unsigned(pos_r, position'length));
		dir		<= dir_r2;
		overflow	<= overflow_r;
		homed		<= homed_r;
		step		<= p_r;
		dirr		<= dir_r;
		err		<= err_r;
		
	end process;
end architecture;
