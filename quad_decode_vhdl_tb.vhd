LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY quad_decode_vhdl_tb IS
END quad_decode_vhdl_tb;

ARCHITECTURE behavior OF quad_decode_vhdl_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT quad_decode_vhdl  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
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
			dirr:			out std_logic
			);
    END COMPONENT;
   
	--declare inputs and initialize them
   signal clk : std_logic := '0';
   signal a : std_logic := '0';
   signal b : std_logic := '0';
   signal z : std_logic := '0';
   signal arst : std_logic := '0';
	
   --declare outputs and initialize them
	signal position: std_logic_vector(13 downto 0);
   signal dir : std_logic;
   signal overflow : std_logic;
   signal homed : std_logic;
   signal step : std_logic;
   signal dirr : std_logic;
	
   -- Clock period definitions
   constant clk_period : time := 1 ns;
	
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: quad_decode_vhdl PORT MAP (
         clk => clk,
          a => a,
          b => b,
          z => z,
          arst => arst,
			 
			 position => position,
			 dir => dir,
			 overflow => overflow,
			 homed => homed,
			 step => step,
			 dirr => dirr
        );      

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
	variable position_i : integer range 0 to 2500 := 0;
	variable i : integer range 0 to 2500 := 0;

   begin
        wait for 1 ns;
		  
        arst <='1';
        a <='0';
        b <='0';
        z <='0';
        wait for 1 ns;
		  
        arst <='0';
        wait for 1 ns;

        z <='1';
        wait for 1 ns;

        z <='0';
        wait for 1 ns;

		  position_i := 0;

 for i in 0 to 10 loop
 
        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 0; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='0';
        b <='1';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='1';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

end loop;


 for i in 0 to 10 loop

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 0; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='0';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

end loop;
		  
		  
		  
		  
		  
        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 0; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='0';
        wait for 1 ns;
		  --position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  position_i := 2499; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='0';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

 for i in 0 to 10 loop

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 0; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='0';
        b <='1';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i - 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

end loop;


 for i in 0 to 10 loop

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 0; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='0';
        b <='1';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='1';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
		  
        a <='1';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));

        a <='0';
        b <='0';
        wait for 1 ns;
		  position_i := position_i + 1; assert(position = std_logic_vector(to_unsigned(position_i, position'length)));
-- does not handle code being stuck at 2499
end loop;

		  
		  assert false report "end of simulation" severity failure;
		  
        wait;
  end process;

END;