LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY test_vhdl IS
	PORT						(
								clk: IN BIT;
								tick: OUT BIT);
END ENTITY;

ARCHITECTURE test_vhdl OF test_vhdl IS
BEGIN
  PROCESS(clk)
    VARIABLE tt: BIT := '0';
  BEGIN 
    IF(clk'EVENT AND clk='1') THEN
		IF(tt='1') THEN
		  tt := '0';
		ELSE
		  tt := '1';
		END IF;
	 END IF;
	 tick <= tt;
  END PROCESS;
END ARCHITECTURE;
