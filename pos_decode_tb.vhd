library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
entity pos_decode_tb is
end pos_decode_tb;

architecture behavior of pos_decode_tb is
   -- Component Declaration for the Unit Under Test (UUT)
    component pos_decode  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
	port	(
			clk: in std_logic;
			rst: in std_logic;
			position: in std_logic_vector(13 downto 0);
			dir: in std_logic;
			overflow: in std_logic;

			bcd1: in std_logic_vector(19 downto 0);
			bcd2: in std_logic_vector(23 downto 0);
			bcd1_er: in std_logic;
			bcd2_er: in std_logic;

			homed: in std_logic;

			m_position: in std_logic_vector(13 downto 0);
			m_dir: in std_logic;
			m_overflow: in std_logic;
			m_homed: in std_logic;

			m_bcd1: in std_logic_vector(19 downto 0);
			m_bcd2: in std_logic_vector(23 downto 0);
			m_bcd1_er: in std_logic;
			m_bcd2_er: in std_logic;
			
			b_select: 	in std_logic;
			b_up: 		in std_logic;
			b_down: 		in std_logic;
			b_left: 		in std_logic;
			b_right: 	in std_logic;

			addr: out std_logic_vector(6 downto 0);
			data: out std_logic_vector(7 downto 0);
			en: 	out std_logic;
			
			ben1: 	out std_logic;
			ben2: 	out std_logic;
			bin1: 	out std_logic;
			bin2: 	out std_logic;

			m_ben1: 	out std_logic;
			m_ben2: 	out std_logic;
			m_bin1: 	out std_logic;
			m_bin2: 	out std_logic
			);
    end component;
   --declare inputs and initialize them
	signal clk: std_logic := '0';
	signal rst: std_logic := '0';
	signal position: std_logic_vector(13 downto 0) := (others => '0');
	signal dir: std_logic := '0';
	signal overflow: std_logic := '0';

	signal bcd1: std_logic_vector(19 downto 0) := (others => '0');
	signal bcd2: std_logic_vector(23 downto 0) := (others => '0');
	signal bcd1_er: std_logic := '0';
	signal bcd2_er: std_logic := '0';

	signal homed: std_logic := '0';

	signal m_position: std_logic_vector(13 downto 0) := (others => '0');
	signal m_dir: std_logic := '0';
	signal m_overflow: std_logic := '0';
	signal m_homed: std_logic := '0';

	signal m_bcd1: 	std_logic_vector(19 downto 0) := (others => '0');
	signal m_bcd2: 	std_logic_vector(23 downto 0) := (others => '0');
	signal m_bcd1_er: std_logic := '0';
	signal m_bcd2_er: std_logic := '0';

	signal b_select: 	std_logic := '0';
	signal b_up: 		std_logic := '0';
	signal b_down: 	std_logic := '0';
	signal b_left: 	std_logic := '0';
	signal b_right: 	std_logic := '0';

	--declare outputs and initialize them
	signal addr: std_logic_vector(6 downto 0) := (others => '0');
	signal data: std_logic_vector(7 downto 0) := (others => '0');
	signal en: std_logic := '0';

	signal ben1: std_logic := '0';
	signal ben2: std_logic := '0';
	signal bin1: std_logic := '0';
	signal bin2: std_logic := '0';

	signal m_ben1: std_logic := '0';
	signal m_ben2: std_logic := '0';
	signal m_bin1: std_logic := '0';
	signal m_bin2: std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 1 ns;
	
begin
    -- Instantiate the Unit Under Test (UUT)
   uut: pos_decode port map (
								clk => clk,
								rst => rst,
								position => position,
								dir => dir,
								overflow => overflow,

								bcd1 => bcd1,
								bcd2 => bcd2,
								bcd1_er => bcd1_er,
								bcd2_er => bcd2_er,
								
								homed => homed,
								
								m_position => m_position,
								m_dir => m_dir,
								m_overflow => m_overflow,
								m_homed => m_homed,
								
								m_bcd1 => m_bcd1,
								m_bcd2 => m_bcd2,
								m_bcd1_er => m_bcd1_er,
								m_bcd2_er => m_bcd2_er,
								
								b_select => b_select,
								b_up => b_up,
								b_down => b_down,
								b_left => b_left,
								b_right => b_right,

								addr => addr,
								data => data,
								en => en,
								
								ben1 => ben1,
								ben2 => ben2,
								bin1 => bin1,
								bin2 => bin2,

								m_ben1 => m_ben1,
								m_ben2 => m_ben2,
								m_bin1 => m_bin1,
								m_bin2 => m_bin2
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
		  rst <= '1';
		  wait for clk_period*2;
		  rst <= '0';
		  wait for clk_period*5;
	  
		  wait for clk_period * 80 * 4;

		  assert false report "end of simulation" severity failure;
		  
        wait;
  end process;

end;