LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY filter IS
	PORT						(
								clk:	IN  std_logic;
								a: 	IN  std_logic;
								z:		out std_logic
								);
END ENTITY;

ARCHITECTURE filter OF filter IS
BEGIN
  PROCESS(clk)
    variable dr: std_logic_vector(3 downto 0) := (others => '0');
    variable zr: std_logic := '0';
  BEGIN 
    IF rising_edge(clk) THEN
	   dr := dr(2 downto 0) & a;

  	   case dr is
	     when "0000" => zr := '0';
		  when "1111" => zr := '1';
		  when others => zr := zr;
	   end case;
	 END IF;
	 
	 z <= zr;
  END PROCESS;
END ARCHITECTURE;
