LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY filter_tb IS
END filter_tb;

ARCHITECTURE behavior OF filter_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT filter  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
	PORT						(
								clk:	IN  std_logic;
								a:		IN  std_logic;
								z:		out std_logic
								);
    END COMPONENT;
   --declare inputs and initialize them
   signal clk : std_logic := '0';
   signal a : std_logic := '0';

   --declare outputs and initialize them
   signal z : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 1 ns;
	
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: filter PORT MAP (
         clk => clk,
          a => a,
          z => z
        );      

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process : process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
--	procedure clkin(constant x : std_logic) is
--	begin
--	  a <= x;
--	  wait for 50 ns;
--	  clk <= '1';
--	  wait for 45ns;
--	  clk <= '0';
--	  wait for 5ns;
--	end procedure;

	variable i : integer range 0 to 2500 := 0;

   begin
        wait for 1 ns;
		  
a <= '0'; wait for clk_period*5;		  
		  
		  assert false report "test 1 3c begin" severity note;
		  a <= '1'; wait for clk_period*3;
		  assert(z = '0');
		  a <= '0'; wait for clk_period*5;
		  assert false report "test 1 3c done" severity note;

a <= '1'; wait for clk_period*5;		  

		  assert false report "test 0 3c begin" severity note;
		  a <= '0'; wait for clk_period*3;
		  assert(z = '1');
		  a <= '1'; wait for clk_period*5;
		  assert false report "test 0 3c done" severity note;

		  
a <= '0'; wait for clk_period*5;		  

		  assert false report "test 1 4c begin" severity note;
		  a <= '1'; wait for clk_period*4;
		  assert(z = '1');
		  a <= '0'; wait for clk_period*5;
		  assert false report "test 1 4c done" severity note;


a <= '1'; wait for clk_period*5;		  

		  assert false report "test 0 4c begin" severity note;
		  a <= '0'; wait for clk_period*4;
		  assert(z = '0');
		  a <= '1'; wait for clk_period*5;
		  assert false report "test 0 4c done" severity note;


a <= '0'; wait for clk_period*5;		  
		  
		  assert false report "test 1 5c begin" severity note;
		  a <= '1'; wait for clk_period*5;
		  assert(z = '1');
		  a <= '0'; wait for clk_period*5;
		  assert false report "test 1 5c done" severity note;


a <= '1'; wait for clk_period*5;		  

		  assert false report "test 0 5c begin" severity note;
		  a <= '0'; wait for clk_period*5;
		  assert(z = '0');
		  a <= '1'; wait for clk_period*5;
		  assert false report "test 0 4c done" severity note;

		  
a <= '0'; wait for clk_period*5;		  

		  assert false report "test 1011 begin" severity note;
  		  a <= '1'; wait for clk_period;
		  a <= '0'; wait for clk_period;
		  a <= '1'; wait for clk_period;
		  a <= '1'; wait for clk_period;
		  assert(z = '0');
		  a <= '0'; wait for clk_period*5;
		  assert false report "test 1011 done" severity note;

		  
a <= '0'; wait for clk_period*5;		  

		  assert false report "test 10111 begin" severity note;
  		  a <= '1'; wait for clk_period;
		  a <= '0'; wait for clk_period;
		  a <= '1'; wait for clk_period;
		  a <= '1'; wait for clk_period;
		  a <= '1'; wait for clk_period;
		  assert(z = '0');
		  a <= '0'; wait for clk_period*5;
		  assert false report "test 10111 done" severity note;


		  
		  assert false report "end of simulation" severity failure;
		  
        wait;
  end process;

END;