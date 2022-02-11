library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pos_decode IS
	port	(
			clk: 			in std_logic;
			rst: 			in std_logic;
			position: 	in std_logic_vector(13 downto 0);
			dir: 			in std_logic;
			overflow: 	in std_logic;

			bcd1: 		in std_logic_vector(19 downto 0);
			bcd2: 		in std_logic_vector(23 downto 0);
			bcd1_er: 	in std_logic;
			bcd2_er: 	in std_logic;

			homed: 		in std_logic;

			m_position: in std_logic_vector(13 downto 0);
			m_dir: 		in std_logic;
			m_overflow:	in std_logic;
			m_homed: 	in std_logic;

			m_bcd1:		in std_logic_vector(19 downto 0);
			m_bcd2:		in std_logic_vector(23 downto 0);
			m_bcd1_er: 	in std_logic;
			m_bcd2_er: 	in std_logic;

			b_select: 	in std_logic;
			b_up: 		in std_logic;
			b_down: 		in std_logic;
			b_left: 		in std_logic;
			b_right: 	in std_logic;


			rpm:			in std_logic_vector(15 downto 0);
			m_rpm:		in std_logic_vector(15 downto 0);
			rpm_bcd:		in std_logic_vector(4*5-1 downto 0); -- 3600.0
			m_rpm_bcd:	in std_logic_vector(4*5-1 downto 0);
			rpm_bcd_er: 	in std_logic;
			m_rpm_bcd_er: 	in std_logic;
			
			addr: 		out std_logic_vector(6 downto 0);
			data: 		out std_logic_vector(7 downto 0);
			en: 			out std_logic;
			
			ben1: 		out std_logic;
			ben2: 		out std_logic;
			bin1: 		out std_logic;
			bin2: 		out std_logic;

			m_ben1: 		out std_logic;
			m_ben2: 		out std_logic;
			m_bin1: 		out std_logic;
			m_bin2: 		out std_logic;
			
			rpm_ben: 	out std_logic;
			m_rpm_ben:	out std_logic;
			rpm_bin: 	out std_logic;
			m_rpm_bin:	out std_logic
			);
end entity;


---- convert hex character to 4 bit signed
--function char_to_sulv4(char : character) return std_ulogic_vector is
--        variable res_sulv4: std_ulogic_vector(3 downto 0);
--begin
--case char is
--when ' ' =>        res_sulv4:="0000";
--when '0' =>        res_sulv4:="0000";
--when '1' =>        res_sulv4:="0001";
--when '2' =>        res_sulv4:="0010";
--when '3' =>        res_sulv4:="0011";
--when '4' =>        res_sulv4:="0100";
--when '5' =>        res_sulv4:="0101";
--when '6' =>        res_sulv4:="0110";
--when '7' =>        res_sulv4:="0111";
--when '8' =>        res_sulv4:="1000";
--when '9' =>        res_sulv4:="1001";
--when 'A' =>        res_sulv4:="1010";
--when 'B' =>        res_sulv4:="1011";
--when 'C' =>        res_sulv4:="1100";
--when 'D' =>        res_sulv4:="1101";
--when 'E' =>        res_sulv4:="1110";
--when 'F' =>        res_sulv4:="1111";
--when others =>        ASSERT (false) REPORT "no hex character read" SEVERITY 
--failure;
--end case;
--return res_sulv4;
--end char_to_sulv4;



architecture pos_decode of pos_decode is
	signal decode_data: 	integer range 0 to 24 := 0;

	signal pos_r:			std_logic_vector(13 downto 0) := (others => '0');
	signal pos_bcd:		std_logic_vector(19 downto 0) := (others => '0'); -- 5 digits * 4 bits per digit
	signal dir_r:			std_logic := '0';
	signal overflow_r: 	std_logic := '0';
	signal homed_r:		std_logic := '0';

	signal cpos:			integer range 0 to 79 := 0; -- character position, 4 rows of 20 characters

	--variable deg:		integer range 0 to 360000; -- deg = pos_r * (360 / 10000) * 1000, when printing we need to insert the decimal point
	signal deg:				std_logic_vector(18 downto 0) := (others => '0'); -- deg = pos_r * (360 / 10000) * 1000, when printing we need to insert the decimal point
	signal deg_bcd:		std_logic_vector(23 downto 0) := (others => '0'); -- 6 digits * 4 bits per digit
	signal bcd1_er_r: 	std_logic := '0';
	signal bcd2_er_r: 	std_logic := '0';

	signal m_pos_r:		std_logic_vector(13 downto 0) := (others => '0');
	signal m_pos_bcd:		std_logic_vector(19 downto 0) := (others => '0'); -- 5 digits * 4 bits per digit
	signal m_dir_r:		std_logic := '0';
	signal m_overflow_r: std_logic := '0';
	signal m_homed_r:		std_logic := '0';

	signal m_deg:			std_logic_vector(18 downto 0) := (others => '0'); -- deg = pos_r * (360 / 10000) * 1000, when printing we need to insert the decimal point
	signal m_deg_bcd:		std_logic_vector(23 downto 0) := (others => '0'); -- 6 digits * 4 bits per digit
	signal m_bcd1_er_r: 	std_logic := '0';
	signal m_bcd2_er_r: 	std_logic := '0';

	signal mode:			integer range 0 to 7 := 0;
	signal mode2a:			integer range 0 to 2 := 0;
	signal mode2b:			integer range 0 to 2 := 0;

	signal rpm_r:			std_logic_vector(15 downto 0) := (others => '0');
	signal m_rpm_r:		std_logic_vector(15 downto 0) := (others => '0');
	signal rpm_bcd_r:		std_logic_vector(4*5-1 downto 0) := (others => '0');
	signal m_rpm_bcd_r:	std_logic_vector(4*5-1 downto 0) := (others => '0'); -- 5 digits * 4 bits per digit
	signal rpm_bcd_er_r: 	std_logic := '0';
	signal m_rpm_bcd_er_r: 	std_logic := '0';

	function bcd_to_ascii(bcd: std_logic_vector) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(to_integer(unsigned("0000" & bcd)) + 48, 8)); --integer(x"30")));
	end function;

	function bcd_to_char(bcd: std_logic_vector) return character is
	begin
		return character'val(to_integer(unsigned("0000" & bcd)) + 48); --integer(x"30")));
	end function;

   function char_to_ascii(c: character) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(character'pos(c), 8));
	end function;





   function dpos(row: integer range 0 to 3; col: integer range 0 to 19) return integer is
		variable rv: integer range 0 to 79; -- character position, 4 rows of 20 characters
	begin
		case row is
			when 0 =>
				rv := 0*20;
			when 1 =>
				rv := 2*20;
			when 2 =>
				rv := 1*20;
			when 3 =>
				rv := 3*20;
		end case;
		return rv + col;
	end function;




--	procedure print_display1a(signal a: std_logic) is
--	begin
--		data <= char_to_ascii(' ');
--		
--		case cpos is
--			when dpos(0, 0) => -- direction
--				if dir_r = '1' then
--					data <= char_to_ascii('+');
--				else
--					data <= char_to_ascii('-');
--				end if;
--				
--			when dpos(0, 2) => -- pos - 10,000
--				data <= bcd_to_ascii(pos_bcd(3 downto 0));
--			when dpos(0, 3) => -- pos - 1,000
--				data <= bcd_to_ascii(pos_bcd(7 downto 4));
--			when dpos(0, 4) => -- pos - 100
--				data <= bcd_to_ascii(pos_bcd(11 downto 8));
--			when dpos(0, 5) => -- pos - 10
--				data <= bcd_to_ascii(pos_bcd(15 downto 12));
--			when dpos(0, 6) => -- pos - 1
--				data <= bcd_to_ascii(pos_bcd(19 downto 16));
--
--			when dpos(0, 10) =>
--				if overflow_r = '1' then
--					data <= char_to_ascii('O');
--				end if;
--			when dpos(0, 11) =>
--				if overflow_r = '1' then
--					data <= char_to_ascii('V');
--				end if;
--			when dpos(0, 12) =>
--				if overflow_r = '1' then
--					data <= char_to_ascii('R');
--				end if;
--
--				
--			when dpos(0, 14) => -- bcd_error
--				if bcd1_er_r = '1' then
--					data <= char_to_ascii('O');
--				end if;
--			when dpos(0, 15) => -- bcd_error
--				if bcd1_er_r = '1' then
--					data <= char_to_ascii('V');
--				end if;
--			when dpos(0, 16) => -- bcd_error
--				if bcd1_er_r = '1' then
--					data <= char_to_ascii('R');
--				end if;
--
--				
--				
--			when dpos(1, 0) => -- direction
--				if dir_r = '1' then
--					data <= char_to_ascii('+');
--				else
--					data <= char_to_ascii('-');
--				end if;
--				
--			when dpos(1, 2) => -- deg - 100
--				data <= bcd_to_ascii(deg_bcd(3 downto 0));
--			when dpos(1, 3) => -- deg - 10
--				data <= bcd_to_ascii(deg_bcd(7 downto 4));
--			when dpos(1, 4) => -- deg - 1
--				data <= bcd_to_ascii(deg_bcd(11 downto 8));
--			when dpos(1, 5) => -- .
--				data <= char_to_ascii('.'); -- .
--			when dpos(1, 6) => -- deg - .1
--				data <= bcd_to_ascii(deg_bcd(15 downto 12));
--			when dpos(1, 7) => -- deg - .01
--				data <= bcd_to_ascii(deg_bcd(19 downto 16));
--			when dpos(1, 8) => -- deg - .001
--				data <= bcd_to_ascii(deg_bcd(23 downto 20));
--
--			when dpos(1, 10) => -- overflow
--				if overflow_r = '1' then
--					data <= char_to_ascii('O');
--				end if;
--			when dpos(1, 11) => -- overflow
--				if overflow_r = '1' then
--					data <= char_to_ascii('V');
--				end if;
--			when dpos(1, 12) => -- overflow
--				if overflow_r = '1' then
--					data <= char_to_ascii('R');
--				end if;
--
--			when dpos(1, 14) => -- bcd_error
--				if bcd2_er_r = '1' then
--					data <= char_to_ascii('O'); -- O
--				end if;
--			when dpos(1, 15) => -- bcd_error
--				if bcd2_er_r = '1' then
--					data <= char_to_ascii('V'); -- V
--				end if;
--			when dpos(1, 16) => -- bcd_error
--				if bcd2_er_r = '1' then
--					data <= char_to_ascii('R'); -- R
--				end if;
--
--				
--				
--
--			when dpos(2, 0) => -- direction
--				if m_dir_r = '1' then
--					data <= char_to_ascii('+'); -- +
--				else
--					data <= char_to_ascii('-'); -- -
--				end if;
--				
--			when dpos(2, 2) => -- pos - 10,000
--				data <= bcd_to_ascii(m_pos_bcd(3 downto 0)); --"0011" & "0000"; -- 0
--			when dpos(2, 3) => -- pos - 1,000
--				data <= bcd_to_ascii(m_pos_bcd(7 downto 4)); --"0011" & "0001"; -- 1
--			when dpos(2, 4) => -- pos - 100
--				data <= bcd_to_ascii(m_pos_bcd(11 downto 8)); --"0011" & "0010"; -- 2
--			when dpos(2, 5) => -- pos - 10
--				data <= bcd_to_ascii(m_pos_bcd(15 downto 12)); --"0011" & "0011"; -- 3
--			when dpos(2, 6) => -- pos - 1
--				data <= bcd_to_ascii(m_pos_bcd(19 downto 16)); --"0011" & "0100"; -- 4
--
--			when dpos(2, 10) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('O');
--				end if;
--			when dpos(2, 11) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('V');
--				end if;
--			when dpos(2, 12) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('R');
--				end if;
--
--				
--			when dpos(2, 14) => -- bcd_error
--				if m_bcd1_er_r = '1' then
--					data <= char_to_ascii('O'); -- O
--				end if;
--			when dpos(2, 15) => -- bcd_error
--				if m_bcd1_er_r = '1' then
--					data <= char_to_ascii('V'); -- V
--				end if;
--			when dpos(2, 16) => -- bcd_error
--				if m_bcd1_er_r = '1' then
--					data <= char_to_ascii('R'); -- R
--				end if;
--
--				
--				
--			when dpos(3, 0) => -- direction
--				if m_dir_r = '1' then
--					data <= char_to_ascii('+');
--				else
--					data <= char_to_ascii('-');
--				end if;
--				
--			when dpos(3, 2) => -- deg - 100
--				data <= bcd_to_ascii(m_deg_bcd(3 downto 0));
--			when dpos(3, 3) => -- deg - 10
--				data <= bcd_to_ascii(m_deg_bcd(7 downto 4));
--			when dpos(3, 4) => -- deg - 1
--				data <= bcd_to_ascii(m_deg_bcd(11 downto 8));
--			when dpos(3, 5) => -- .
--				data <= char_to_ascii('.'); -- .
--			when dpos(3, 6) => -- deg - .1
--				data <= bcd_to_ascii(m_deg_bcd(15 downto 12));
--			when dpos(3, 7) => -- deg - .01
--				data <= bcd_to_ascii(m_deg_bcd(19 downto 16));
--			when dpos(3, 8) => -- deg - .001
--				data <= bcd_to_ascii(m_deg_bcd(23 downto 20));
--
--			when dpos(3, 10) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('O');
--				end if;
--			when dpos(3, 11) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('V');
--				end if;
--			when dpos(3, 12) => -- overflow
--				if m_overflow_r = '1' then
--					data <= char_to_ascii('R');
--				end if;
--
--			when dpos(3, 14) => -- bcd_error
--				if m_bcd2_er_r = '1' then
--					data <= char_to_ascii('O'); -- O
--				end if;
--			when dpos(3, 15) => -- bcd_error
--				if m_bcd2_er_r = '1' then
--					data <= char_to_ascii('V'); -- V
--				end if;
--			when dpos(3, 16) => -- bcd_error
--				if m_bcd2_er_r = '1' then
--					data <= char_to_ascii('R'); -- R
--				end if;
--
--				
--				
--
----					when dpos(2, 10) => -- homed
----						if homed_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----					when 51 => -- overflow
----						if overflow_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----			when 80 => -- sentry character
----				data <= "1111" & "1111"; -- (solid block)
--			
--			when others =>
--				data <= char_to_ascii(' '); -- ' '
--				--data <= "1111" & "1111"; -- (solid block)
--		end case;
--	end procedure;
--
--	
--	procedure print_display1b(signal a: std_logic) is
--	  constant str_ovr : string := "OVR";
--	begin
--		data <= char_to_ascii(' ');
--
--		if cpos = dpos(0, 0) then
--			if dir_r = '1' then
--				data <= char_to_ascii('+');
--			else
--				data <= char_to_ascii('-');
--			end if;
--		elsif dpos(0, 2) <= cpos and cpos <= dpos(0, 6) then
--			data <= bcd_to_ascii(pos_bcd(((cpos - dpos(0, 2)) * 4 + 3) downto ((cpos - dpos(0, 2)) * 4)));
--		elsif dpos(0, 10) <= cpos and cpos <= dpos(0, 12) then
--			if overflow_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(0, 10) + 1));
--			end if;
--		elsif dpos(0, 14) <= cpos and cpos <= dpos(0, 16) then
--			if bcd1_er_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(0, 14) + 1));
--			end if;
--		elsif cpos = dpos(1, 0) then -- direction
--			if dir_r = '1' then
--				data <= char_to_ascii('+');
--			else
--				data <= char_to_ascii('-');
--			end if;
--		--elsif dpos(1, 2) <= cpos and cpos <= dpos(1, 8) then
--		elsif dpos(1, 2) <= cpos and cpos <= dpos(1, 4) then
--			data <= bcd_to_ascii(deg_bcd(((cpos - dpos(1, 2)) * 4 + 3) downto ((cpos - dpos(1, 2)) * 4)));
--		elsif dpos(1, 5) = cpos then
--			data <= char_to_ascii('.'); -- .
--		elsif dpos(1, 6) <= cpos and cpos <= dpos(1, 8) then
--			data <= bcd_to_ascii(deg_bcd(((cpos - dpos(1, 6)) * 4 + 3 + 12) downto ((cpos - dpos(1, 6)) * 4 + 12)));
--		elsif dpos(1, 10) <= cpos and cpos <= dpos(1, 12) then
--			if overflow_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(1, 10) + 1));
--			end if;
--		elsif dpos(1, 14) <= cpos and cpos <= dpos(1, 16) then
--			if bcd2_er_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(1, 14) + 1));
--			end if;
--		elsif cpos = dpos(2, 0) then -- direction
--			if m_dir_r = '1' then
--				data <= char_to_ascii('+'); -- +
--			else
--				data <= char_to_ascii('-'); -- -
--			end if;
--		elsif dpos(2, 2) <= cpos and cpos <= dpos(2, 6) then
--			data <= bcd_to_ascii(m_pos_bcd(((cpos - dpos(2, 2)) * 4 + 3) downto ((cpos - dpos(2, 2)) * 4)));
--		elsif dpos(2, 10) <= cpos and cpos <= dpos(2, 12) then
--			if m_overflow_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(2, 10) + 1));
--			end if;
--		elsif dpos(2, 14) <= cpos and cpos <= dpos(2, 16) then
--			if m_bcd1_er_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(2, 14) + 1));
--			end if;
--		elsif cpos = dpos(3, 0) then -- direction
--			if m_dir_r = '1' then
--				data <= char_to_ascii('+');
--			else
--				data <= char_to_ascii('-');
--			end if;
--		--elsif dpos(3, 2) <= cpos and cpos <= dpos(3, 8) then
--		elsif dpos(3, 2) <= cpos and cpos <= dpos(3, 4) then
--			data <= bcd_to_ascii(m_deg_bcd(((cpos - dpos(3, 2)) * 4 + 3) downto ((cpos - dpos(3, 2)) * 4)));
--		elsif dpos(3, 5) = cpos then
--			data <= char_to_ascii('.'); -- .
--		elsif dpos(3, 6) <= cpos and cpos <= dpos(3, 8) then
--			data <= bcd_to_ascii(m_deg_bcd(((cpos - dpos(3, 6)) * 4 + 3 + 12) downto ((cpos - dpos(3, 6)) * 4 + 12)));
--		--end if;
--		elsif dpos(3, 10) <= cpos and cpos <= dpos(3, 12) then
--			if m_overflow_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(3, 10) + 1));
--			end if;
--		elsif dpos(3, 14) <= cpos and cpos <= dpos(3, 16) then
--			if bcd2_er_r = '1' then
--				data <= char_to_ascii(str_ovr(cpos - dpos(3, 14) + 1));
--			end if;
----		elsif cpos = 80 then -- sentry character
----				data <= "1111" & "1111"; -- (solid block)
--		end if;
--
--				
--				
--
----					if cpos = dpos(2, 10) then -- homed
----						if homed_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----					if cpos = 51 then -- overflow
----						if overflow_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
--
--			
--	end procedure;
--
--	procedure print_display1c(signal a: std_logic) is
--	  constant str_ovr : string := "OVR";
--	  variable test: std_logic_vector(20*8-1 downto 0);
--	  variable col: integer range 0 to 19;
--	  variable row: integer range 0 to 3;
--	begin
--		data <= char_to_ascii(' ');
--
--		if dpos(0, 0) <= cpos and cpos <= dpos(0, 19) then
--			row := 0;
--		elsif dpos(1, 0) <= cpos and cpos <= dpos(1, 19) then
--			row := 1;
--		elsif dpos(2, 0) <= cpos and cpos <= dpos(2, 19) then
--			row := 2;
--		elsif dpos(3, 0) <= cpos and cpos <= dpos(3, 19) then
--			row := 3;
--		end if;
--		
--		col := cpos - dpos(row, 0);
--				
--		for i in 0 to 19 loop
--			test((19 - i + 1)*8-1 downto (19 - i)*8) := char_to_ascii(' ');
--		end loop;
--		
--		case row is
--		when 0 =>
--			if dir_r = '1' then
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('+');
--			else
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('-');
--			end if;
--			for i in 0 to 4 loop
--				test((19 - 2 - i + 1)*8-1 downto (19 - 2 - i)*8) := bcd_to_ascii(pos_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			if overflow_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 10 - i + 1)*8-1 downto (19 - 10 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--			if bcd1_er_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 14 - i + 1)*8-1 downto (19 - 14 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--		when 1 =>
--			if dir_r = '1' then
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('+');
--			else
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('-');
--			end if;
--			for i in 0 to 2 loop
--				test((19 - 2 - i + 1)*8-1 downto (19 - 2 - i)*8) := bcd_to_ascii(deg_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			test((19 - 5 - 0 + 1)*8-1 downto (19 - 5 - 0)*8) := char_to_ascii('.');
--			for i in 0 to 2 loop
--				test((19 - 6 - i + 1)*8-1 downto (19 - 6 - i)*8) := bcd_to_ascii(deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--			end loop;
--			if overflow_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 10 - i + 1)*8-1 downto (19 - 10 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--			if bcd2_er_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 14 - i + 1)*8-1 downto (19 - 14 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--		when 2 =>
--			if m_dir_r = '1' then
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('+');
--			else
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('-');
--			end if;
--			for i in 0 to 4 loop
--				test((19 - 2 - i + 1)*8-1 downto (19 - 2 - i)*8) := bcd_to_ascii(m_pos_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			if m_overflow_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 10 - i + 1)*8-1 downto (19 - 10 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--			if m_bcd1_er_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 14 - i + 1)*8-1 downto (19 - 14 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--		when 3 =>
--			if m_dir_r = '1' then
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('+');
--			else
--				test((19 - 0 + 1)*8-1 downto (19 - 0)*8) := char_to_ascii('-');
--			end if;
--			for i in 0 to 2 loop
--				test((19 - 2 - i + 1)*8-1 downto (19 - 2 - i)*8) := bcd_to_ascii(m_deg_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			test((19 - 5 - 0 + 1)*8-1 downto (19 - 5 - 0)*8) := char_to_ascii('.');
--			for i in 0 to 2 loop
--				test((19 - 6 - i + 1)*8-1 downto (19 - 6 - i)*8) := bcd_to_ascii(m_deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--			end loop;
--			if m_overflow_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 10 - i + 1)*8-1 downto (19 - 10 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--			if m_bcd2_er_r = '1' then
--				for i in 0 to 2 loop
--					test((19 - 14 - i + 1)*8-1 downto (19 - 14 - i)*8) := char_to_ascii(str_ovr(i+1)); --bcd_to_ascii(pos_bcd((i * 4 + 3) downto (i * 4)));
--				end loop;
--			end if;
--		end case;
--
--		data <= test((19 - col + 1)*8-1 downto (19 - col)*8);
--
----					if cpos = dpos(2, 10) then -- homed
----						if homed_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----					if cpos = 51 then -- overflow
----						if overflow_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
--
--			
--	end procedure;
--
--	procedure print_display1d(signal a: std_logic) is
--	  constant str_ovr : string := "OVR";
--	  variable test: string(1 to 20);
--	  variable col: integer range 1 to 20;
--	  variable row: integer range 1 to 4;
--	begin
--		data <= char_to_ascii(' ');
--
--		if dpos(0, 0) <= cpos and cpos <= dpos(0, 19) then
--			row := 1;
--		elsif dpos(1, 0) <= cpos and cpos <= dpos(1, 19) then
--			row := 2;
--		elsif dpos(2, 0) <= cpos and cpos <= dpos(2, 19) then
--			row := 3;
--		elsif dpos(3, 0) <= cpos and cpos <= dpos(3, 19) then
--			row := 4;
--		end if;
--		
--		col := cpos - dpos(row-1, 0) + 1;
--				
--		for i in 1 to 20 loop
--			test(i) := ' ';
--		end loop;
--		
--		case row is
--		when 1 =>
--			if dir_r = '1' then
--				test(1) := '+';
--			else
--				test(1) := '-';
--			end if;
--			for i in 0 to 4 loop
--				test(3 + i) := bcd_to_char(pos_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			if overflow_r = '1' then
--				for i in 0 to 2 loop
--					test(11 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--			if bcd1_er_r = '1' then
--				for i in 0 to 2 loop
--					test(15 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--		when 2 =>
--			if dir_r = '1' then
--				test(1) := '+';
--			else
--				test(1) := '-';
--			end if;
--			for i in 0 to 2 loop
--				test(3 + i) := bcd_to_char(deg_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			test(6) := '.';
--			for i in 0 to 2 loop
--				test(7 + i) := bcd_to_char(deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--			end loop;
--			if overflow_r = '1' then
--				for i in 0 to 2 loop
--					test(11 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--			if bcd2_er_r = '1' then
--				for i in 0 to 2 loop
--					test(15 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--		when 3 =>
--			if m_dir_r = '1' then
--				test(1) := '+';
--			else
--				test(1) := '-';
--			end if;
--			for i in 0 to 4 loop
--				test(3 + i) := bcd_to_char(m_pos_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			if m_overflow_r = '1' then
--				for i in 0 to 2 loop
--					test(11 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--			if m_bcd1_er_r = '1' then
--				for i in 0 to 2 loop
--					test(15 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--		when 4 =>
--			if m_dir_r = '1' then
--				test(1) := '+';
--			else
--				test(1) := '-';
--			end if;
--			for i in 0 to 2 loop
--				test(3 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 downto i * 4));
--			end loop;
--			test(6) := '.';
--			for i in 0 to 2 loop
--				test(7 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--			end loop;
--			if m_overflow_r = '1' then
--				for i in 0 to 2 loop
--					test(11 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--			if m_bcd2_er_r = '1' then
--				for i in 0 to 2 loop
--					test(15 + i) := str_ovr(i+1);
--				end loop;
--			end if;
--		end case;
--
--		data <= char_to_ascii(test(col));
--
----					if cpos = dpos(2, 10) then -- homed
----						if homed_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----					if cpos = 51 then -- overflow
----						if overflow_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
--
--			
--	end procedure;
--
--procedure print_display1e(signal a: std_logic) is
--	  constant str_ovr : string := "OVR";
--	  type disp_buf is array (1 to 4) of string(1 to 20);
--	  variable test: disp_buf; -- := (others => ' ');
--	  variable col: integer range 1 to 20;
--	  variable row: integer range 1 to 4;
--	begin
--		data <= char_to_ascii(' ');
--
--		if dpos(0, 0) <= cpos and cpos <= dpos(0, 19) then
--			row := 1;
--		elsif dpos(1, 0) <= cpos and cpos <= dpos(1, 19) then
--			row := 2;
--		elsif dpos(2, 0) <= cpos and cpos <= dpos(2, 19) then
--			row := 3;
--		elsif dpos(3, 0) <= cpos and cpos <= dpos(3, 19) then
--			row := 4;
--		end if;
--		
--		col := cpos - dpos(row-1, 0) + 1;
--				
--		for j in 1 to 4 loop
--			for i in 1 to 20 loop
--				test(j)(i) := ' ';
--			end loop;
--		end loop;
--		
--		if dir_r = '1' then
--			test(1)(1) := '+';
--		else
--			test(1)(1) := '-';
--		end if;
--		for i in 0 to 4 loop
--			test(1)(3 + i) := bcd_to_char(pos_bcd(i * 4 + 3 downto i * 4));
--		end loop;
--		if overflow_r = '1' then
--			for i in 1 to str_ovr'length loop
--				test(1)(12 + i) := str_ovr(i);
--			end loop;
--		end if;
--		if bcd1_er_r = '1' then
--			for i in 1 to str_ovr'length loop
--				test(1)(16 + i) := str_ovr(i);
--			end loop;
--		end if;
--
--		if dir_r = '1' then
--			test(2)(1) := '+';
--		else
--			test(2)(1) := '-';
--		end if;
--		for i in 0 to 2 loop
--			test(2)(3 + i) := bcd_to_char(deg_bcd(i * 4 + 3 downto i * 4));
--		end loop;
--		test(2)(6) := '.';
--		for i in 0 to 2 loop
--			test(2)(7 + i) := bcd_to_char(deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--		end loop;
--		if overflow_r = '1' then
--			for i in 0 to 2 loop
--				test(2)(11 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--		if bcd2_er_r = '1' then
--			for i in 0 to 2 loop
--				test(2)(15 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--
--		if m_dir_r = '1' then
--			test(3)(1) := '+';
--		else
--			test(3)(1) := '-';
--		end if;
--		for i in 0 to 4 loop
--			test(3)(3 + i) := bcd_to_char(m_pos_bcd(i * 4 + 3 downto i * 4));
--		end loop;
--		if m_overflow_r = '1' then
--			for i in 0 to 2 loop
--				test(3)(11 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--		if m_bcd1_er_r = '1' then
--			for i in 0 to 2 loop
--				test(3)(15 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--
--		if m_dir_r = '1' then
--			test(4)(1) := '+';
--		else
--			test(4)(1) := '-';
--		end if;
--		for i in 0 to 2 loop
--			test(4)(3 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 downto i * 4));
--		end loop;
--		test(4)(6) := '.';
--		for i in 0 to 2 loop
--			test(4)(7 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
--		end loop;
--		if m_overflow_r = '1' then
--			for i in 0 to 2 loop
--				test(4)(11 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--		if m_bcd2_er_r = '1' then
--			for i in 0 to 2 loop
--				test(4)(15 + i) := str_ovr(i+1);
--			end loop;
--		end if;
--	
--		data <= char_to_ascii(test(row)(col));
--
----					if cpos = dpos(2, 10) then -- homed
----						if homed_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
----
----					if cpos = 51 then -- overflow
----						if overflow_r = '1' then
----							data <= "0100" & "1111"; -- O
----						else
----							data <= "1111" & "1111"; -- (solid block)
----						end if;
--
--			
--	end procedure;


begin
	process (clk) -- print_display1
	  constant str_ovr : string := "OVR";
	  type disp_buf is array (1 to 4) of string(1 to 20);
	  variable test: disp_buf; -- := (others => ' ');
	  variable col: integer range 1 to 20;
	  variable row: integer range 1 to 4;
	begin
		if rising_edge(clk) then
			if decode_data = 24 then 
				data <= char_to_ascii(' ');

				if dpos(0, 0) <= cpos and cpos <= dpos(0, 19) then
					row := 1;
				elsif dpos(1, 0) <= cpos and cpos <= dpos(1, 19) then
					row := 2;
				elsif dpos(2, 0) <= cpos and cpos <= dpos(2, 19) then
					row := 3;
				elsif dpos(3, 0) <= cpos and cpos <= dpos(3, 19) then
					row := 4;
				end if;
				
				col := cpos - dpos(row-1, 0) + 1;
						
				for j in 1 to 4 loop
					for i in 1 to 20 loop
						test(j)(i) := ' ';
					end loop;
				end loop;
				
				case mode2a is
					when 0 => -- display pulse position of spindle
						for i in 0 to 4 loop
							test(1)(3 + i) := bcd_to_char(pos_bcd(i * 4 + 3 downto i * 4));
						end loop;
					when 1 => -- display degree position of spindle
						for i in 0 to 2 loop
							test(1)(3 + i) := bcd_to_char(deg_bcd(i * 4 + 3 downto i * 4));
						end loop;
						test(1)(6) := '.';
						for i in 0 to 2 loop
							test(1)(7 + i) := bcd_to_char(deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
						end loop;				
					when 2 => -- display degree position of spindle
						for i in 0 to 3 loop
							test(1)(3 + i) := bcd_to_char(rpm_bcd_r(i * 4 + 3 downto i * 4));
						end loop;
						test(1)(7) := '.';
						for i in 0 to 0 loop
							test(1)(8 + i) := bcd_to_char(rpm_bcd_r(i * 4 + 3 + 16 downto i * 4 + 16));
						end loop;				
				end case;

				case mode2b is
					when 0 => -- display pulse position of motor
						for i in 0 to 4 loop
							test(3)(3 + i) := bcd_to_char(m_pos_bcd(i * 4 + 3 downto i * 4));
						end loop;
					when 1 => -- display degree position of motor
						for i in 0 to 2 loop
							test(3)(3 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 downto i * 4));
						end loop;
						test(3)(6) := '.';
						for i in 0 to 2 loop
							test(3)(7 + i) := bcd_to_char(m_deg_bcd(i * 4 + 3 + 12 downto i * 4 + 12));
						end loop;
					when 2 => -- display degree position of motor
						for i in 0 to 3 loop
							test(3)(3 + i) := bcd_to_char(m_rpm_bcd_r(i * 4 + 3 downto i * 4));
						end loop;
						test(3)(7) := '.';
						for i in 0 to 0 loop
							test(3)(8 + i) := bcd_to_char(m_rpm_bcd_r(i * 4 + 3 + 16 downto i * 4 + 16));
						end loop;
				end case;

			
--				if 1 = 1 then
--					for i in 1 to 16 loop
--						if m_rpm(15-(i-1)) = '1' then
--							test(4)(i) := '1';
--						else
--							test(4)(i) := '0';
--						end if;
--					end loop;
--				else
				if homed_r = '1' then
					test(4)(1) := 'H';
				end if;
				if m_homed_r = '1' then
					test(4)(2) := 'H';
				end if;
				if dir_r = '1' then
					test(4)(3) := '+';
				else
					test(4)(3) := '-';
				end if;
				if m_dir_r = '1' then
					test(4)(4) := '+';
				else
					test(4)(4) := '-';
				end if;
				if b_up = '1' then
					test(4)(5) := 'U';
				end if;
				if b_down = '1' then
					test(4)(6) := 'D';
				end if;
				if b_left = '1' then
					test(4)(7) := 'L';
				end if;
				if b_right = '1' then
					test(4)(8) := 'R';
				end if;
				if b_select = '1' then
					test(4)(9) := 'C';
				end if;
				if rpm_bcd_er_r = '1' then
					test(4)(13) := '!';
				end if;
				if m_rpm_bcd_er_r = '1' then
					test(4)(14) := '!';
				end if;
				if overflow_r = '1' then
					test(4)(15) := '!';
				end if;
				if m_overflow_r = '1' then
					test(4)(16) := '!';
				end if;
				if bcd1_er_r = '1' then
					test(4)(17) := '!';
				end if;
				if bcd2_er_r = '1' then
					test(4)(18) := '!';
				end if;
				if m_bcd1_er_r = '1' then
					test(4)(19) := '!';
				end if;
				if m_bcd2_er_r = '1' then
					test(4)(20) := '!';
				end if;
--				end if;
				
				data <= char_to_ascii(test(row)(col));
			end if;
		end if;
	end process;

	process(b_left, b_right) -- handle stick controller
	begin
		if rising_edge(b_right) then
			case mode2a is
				when 0 =>
					mode2a <= 1;
				when 1 =>
					mode2a <= 2;
				when 2 =>
					mode2a <= 0;
			end case;
		end if;
		if rising_edge(b_left) then
			case mode2b is
				when 0 =>
					mode2b <= 1;
				when 1 =>
					mode2b <= 2;
				when 2 =>
					mode2b <= 0;
			end case;
		end if;
	end process;

	process(clk) -- load data
	begin
		if rising_edge(clk) then
			ben1 <= '0';
			ben2 <= '0';

			m_ben1 <= '0';
			m_ben2 <= '0';

			rpm_ben <= '0';
			m_rpm_ben <= '0';

			if (rst = '1') then
				decode_data <= 0;
			else
				if cpos = 79 then
					decode_data <= 0;
				end if;

				if 0 <= decode_data and decode_data < 24 then 
					decode_data <= decode_data + 1;
					
					if decode_data = 0 then -- latch the input when starting a refresh cycle
						pos_r <= position;
						dir_r <= dir;
						overflow_r <= overflow;
						homed_r <= homed;

						deg	<= std_logic_vector(to_unsigned(to_integer(unsigned(position)) * 36, deg'length));

						m_pos_r <= m_position;
						m_dir_r <= m_dir;
						m_overflow_r <= m_overflow;
						m_homed_r <= m_homed;
						
						m_deg	<= std_logic_vector(to_unsigned(to_integer(unsigned(m_position)) * 36, deg'length));

						ben1 <= '1';
						ben2 <= '1';

						m_ben1 <= '1';
						m_ben2 <= '1';

						rpm_r <= rpm;
						m_rpm_r <= m_rpm;
						
						rpm_ben <= '1';
						m_rpm_ben <= '1';
					else
						if decode_data <= 15 then
						  bin1 <= pos_r(13);
						  pos_r <= pos_r(12 downto 0) & '0';

						  m_bin1 <= m_pos_r(13);
						  m_pos_r <= m_pos_r(12 downto 0) & '0';
						end if;
						if decode_data = 16 then
							pos_bcd <= bcd1;
							bcd1_er_r <= bcd1_er;

							m_pos_bcd <= m_bcd1;
							m_bcd1_er_r <= m_bcd1_er;
						end if;

						if decode_data <= 17 then
						  rpm_bin <= rpm_r(15);
						  rpm_r <= rpm_r(14 downto 0) & '0';

						  m_rpm_bin <= m_rpm_r(15);
						  m_rpm_r <= m_rpm_r(14 downto 0) & '0';
						end if;
						if decode_data = 18 then
							rpm_bcd_r <= rpm_bcd;
							rpm_bcd_er_r <= rpm_bcd_er;

							m_rpm_bcd_r <= m_rpm_bcd;
							m_rpm_bcd_er_r <= m_rpm_bcd_er;
						end if;
						
						if decode_data <= 20 then
						  bin2 <= deg(18);
						  deg <= deg(17 downto 0) & '0';

						  m_bin2 <= m_deg(18);
						  m_deg <= m_deg(17 downto 0) & '0';
						end if;
						if decode_data = 21 then
							deg_bcd <= bcd2;
							bcd2_er_r <= bcd2_er;

							m_deg_bcd <= m_bcd2;
							m_bcd2_er_r <= m_bcd2_er;
						end if;
						
--						if decode_data = 22 then
--			--					pos_bcd <= bcd1;
--			--					deg_bcd <= bcd2;
--							cpos <= 0;
--						end if;
--						
						if decode_data = 23 then
							ben1 <= '0';
							ben2 <= '0';

							m_ben1 <= '0';
							m_ben2 <= '0';

							rpm_ben <= '0';
							m_rpm_ben <= '0';
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
			en <= '0';

			if (rst = '1') then
				mode <= 0;
			else
				if decode_data = 22 then
					cpos <= 0;
				end if;
						
				if decode_data = 24 then 
					en <= '1';
					addr <= std_logic_vector(to_unsigned(cpos, addr'length));

					if cpos < 79 then
						cpos <= cpos + 1;
					else
						cpos <= 0;
--						decode_data <= 0;
					end if;
					
					--print_display1(clk);
				end if;
			end if;
		end if;		
	end process;
end architecture;
