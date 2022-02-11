library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_display_vhdl is
	port	(
			clk:		in std_logic;
			char_in:	in std_logic_vector(7 downto 0);
			arst:		in std_logic;

			rs:		out std_logic; -- register select: 1: data register (r/w), 0: instruction register (w) or busy flag address counter (r)
			rw:		out std_logic; -- 1: read mode, 0: write mode
			e:			out std_logic; -- enable for writing or reading

			--db:		inout std_logic_vector(3 DOWNTO 0) -- first MSB 4 bits, then LSB 4 bits
			db:		out std_logic_vector(3 downto 0); -- first MSB 4 bits, then LSB 4 bits

			rd_addr:	out std_logic_vector(6 downto 0);
			rd_e:		out std_logic
			);
end entity;

architecture lcd_display_vhdl of lcd_display_vhdl is
	constant clk_period : time := 100 us; -- 10kHz clock, display's minimum pulse width is 150ns, and display's minimum cycle time is 400ns.
	
   function calc_delay(delay : time) return integer is
	begin
		return delay / clk_period + 2; -- two extra cc, one for rounding error and for good luck
	end function;
	
begin
	process(clk, arst)
		variable e_r:			std_logic := '0';
		variable db_r:			std_logic_vector(3 downto 0) := (others => '0');

		variable rd_addr_r:	std_logic_vector(6 downto 0) := (others => '0');
		variable	rd_e_r:		std_logic := '0';
		
		variable rsrw_r:		std_logic_vector(1 downto 0);
		variable dd:			std_logic_vector(7 downto 0); -- byte to send, MS 4-bits first, then LS 4-bits

		variable state:		integer range 0 to 14 := 0;
		variable state2:		integer range 0 to 2 := 0;
		variable state3:		integer range 0 to 1 := 0;

		variable cdelay:		integer range 0 to 1000 := 0;
		variable delay:		integer range 0 to 1000 := 0;

	begin
		if arst = '1' then
			state		:= 0;
			cdelay	:= 0;
			delay		:= 0;
			e_r		:= '0';
			rd_e_r	:= '0';
		elsif rising_edge(clk) then
			if delay > 0 then 
				if cdelay < delay then
					-- pulse the enable line - first cc: e_r=1, all other cc: e_r=0
					if cdelay = 0 then
						e_r := '1';
					else
						e_r := '0';
					end if;
					cdelay := cdelay + 1;
				elsif cdelay >= delay then
					e_r		:= '0';
					delay		:= 0;
					cdelay	:= 0;
				end if;
			else
				case state is
					when 0 =>  -- wait > 40ms
						delay := calc_delay(50 ms);
						state := state + 1;
					
			-- three pulses of the same command, set 4-bit, or perhaps a special function set for synchronizing with the display
					when 1 => -- function set -- wait > 4.1ms
						rsrw_r	:= "00";
						db_r 		:= "0011";
						delay 	:= calc_delay(4.2 ms);
						state 	:= state + 1;
					when 2 => -- function set -- wait > 100us
						rsrw_r	:= "00";
						db_r 		:= "0011";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
					when 3 => -- function set -- wait > 100us
						rsrw_r	:= "00";
						db_r 		:= "0011";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
			 -- appears to be an empty function set command, ending the 4-bit set protocol, but only MSBs
					when 4 => -- function set -- wait > 100us
						rsrw_r	:= "00";
						db_r		:= "0010";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
					
			 -- function set, set number of lines and font type
					when 5 => -- function set -- wait > 100us MSB
						rsrw_r	:= "00";
						db_r		:= "0010";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
					when 6 => -- function set -- wait > 100us LSB
						--db_r := "00NFxx"; -- 
						rsrw_r	:= "00";
						db_r		:= "1000"; -- set number of lines, and font type
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;

			 -- entry mode set
					when 7 => -- function set -- wait > 100us MSB
						rsrw_r	:= "00";
						db_r		:= "0000";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
					when 8 => -- function set -- wait > 100us LSB
						--db_r := "0001 I/D S"; -- cursor moving direction and display shift
						rsrw_r	:= "00";
						db_r		:= "0100";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;

			 -- display on/off control
					when 9 => -- function set -- wait > 100us MSB
						rsrw_r	:= "00";
						db_r		:= "0000";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;
					when 10 => -- function set -- wait > 100us LSB
						--db_r := "001 D C B"; -- set display, cursor, and blinking
						rsrw_r	:= "00";
						db_r		:= "1111";
						delay 	:= calc_delay(100 us);
						state 	:= state + 1;

			 -- clear display (also homes)
					when 11 => -- function set -- wait > 100us MSB
						rsrw_r	:= "00";
						db_r		:= "0000";
						delay 	:= calc_delay(2.2 ms);
						state 	:= state + 1;
					when 12 => -- function set -- wait > 100us LSB
						rsrw_r	:= "00";
						db_r		:= "0001";
						delay 	:= calc_delay(2.2 ms);
						state 	:= state + 1;

			 -- initialization complete
					when 13 =>
						state2	:= 0;
						state3	:= 0;
						state		:= state + 1;

						rd_addr_r := (others => '0');
						
					when 14 =>
						rd_e_r := '0';
						
						if state2 > 0 then
							if rsrw_r = "00" then	-- homing or clearing display
								delay := calc_delay(2.2 ms);
							else						-- writting character
								delay := calc_delay(100 us);
							end if;
							
							if state2 = 1 then		-- MS 4-bits
								db_r		:= dd(7 downto 4);
								state2	:= 2;
							elsif state2 = 2  then	-- LS 4-bits
								db_r		:= dd(3 downto 0);
								state2	:= 0;
							end if;
						elsif state3 = 0 then -- increment RAM addr, home display if wrapping around, enable RAM read request
							if rd_addr_r = std_logic_vector(to_unsigned(79, rd_addr_r'length)) then
								rd_addr_r := (others => '0');
							else 
								rd_addr_r := std_logic_vector(unsigned(rd_addr_r) + 1);
							end if;
								-- since we are cycling through all character position, there is no need to home the display between refreshes
								-- in the time that a home operation would take to complete, 20 characters can be written
								-- home display
					--			rsrw_r	:= "00";
					--			dd			:= "0000" & "0010";
					--			state2 	:= 1;
							--else
								--rd_addr_r := std_logic_vector(unsigned(rd_addr_r) + 1);
							--end if;
							rd_e_r := '1';
							state3 := state3 + 1;
							
						elsif state3 = 1 then -- latch RAM value, disable RAM read request, request value be sent to display
							--rd_e_r := '0';
							--char_in_r := char_in;

							rsrw_r	:= "10";
							dd			:= char_in;
							state2	:= 1;
							state3	:= 0;
							
							-- set up address for next read
							--if rd_addr_r /= std_logic_vector(to_unsigned(79, rd_addr_r'length)) then
								--rd_addr_r := std_logic_vector(unsigned(rd_addr_r) + 1);
							--end if;
						end if;
				end case;
			end if;
		end if;

		rs <= rsrw_r(1);
		rw <= rsrw_r(0);
		db	<= db_r;
		e	<= e_r;

		rd_e		<= rd_e_r;
		rd_addr	<= rd_addr_r;
		
	end process;
end architecture;
