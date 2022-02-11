library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
entity lcd_display_vhdl_tb is
end lcd_display_vhdl_tb;

architecture behavior of lcd_display_vhdl_tb is
   -- Component Declaration for the Unit Under Test (UUT)
	component lcd_display_vhdl  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
	port	(
			clk:		in std_logic;
			char_in:	in std_logic_vector(7 downto 0);
			arst:		in std_logic;

			rs:		out std_logic; -- register select: 1: data register (r/w), 0: instruction register (w) or busy flag address counter (r)
			rw:		out std_logic; -- 1: read mode, 0: write mode
			e:			out std_logic; -- enable for writing or reading

			db:		out std_logic_vector(3 downto 0); -- first MSB 4 bits, then LSB 4 bits

			rd_addr:	out std_logic_vector(6 downto 0);
			rd_e:		out std_logic
			);
			
	end component;
   --declare inputs and initialize them
   signal clk:			std_logic := '0';
	signal char_in:	std_logic_vector(7 downto 0) := (others => '0');
   signal arst: 		std_logic := '0';
	
   --declare outputs and initialize them
   signal rs : std_logic := '0';
   signal rw : std_logic := '0';
   signal e : std_logic := '0';

   signal db : std_logic_vector(3 downto 0) := (others => '0');

	signal rd_addr:	std_logic_vector(6 downto 0) := (others => '0');
	signal rd_e:		std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 100 us;
	
begin
    -- Instantiate the Unit Under Test (UUT)
   uut: lcd_display_vhdl port map (
								clk => clk,
								char_in => char_in,
								arst => arst,

								rs => rs,
								rw => rw,
								e => e,
								db => db,
								
								rd_addr => rd_addr,
								rd_e => rd_e
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
   begin
        wait for clk_period*2;
		  arst <= '1';
		  wait for clk_period*2;
		  arst <= '0';
		  wait for clk_period*5;
	  
		  wait for 100 ms;

		  char_in <= "1010" & "1111";

		  wait for 300 ms;
		  
		  assert false report "end of simulation" severity failure;
		  
        wait;
  end process;

end;