library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
entity stepper_controller_tb is
end stepper_controller_tb;

architecture behavior of stepper_controller_tb is
   -- Component Declaration for the Unit Under Test (UUT)
	component stepper_controller  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
	port	(
			clk:			in std_logic;
			rst:			in std_logic;

			desired_position:	in std_logic_vector(13 downto 0);
			current_position:	in std_logic_vector(13 downto 0);

			jog_left:	in std_logic;
			jog_right:	in std_logic;

			dir:				in std_logic; -- 0=reverse, 1=forward
			shortest_path:	in std_logic;

			mode:	in std_logic; -- 0=jog, 1=go to desired position

			m_move:		out std_logic;
			m_dir:		out std_logic;
			
			pos_error:	out std_logic_vector(14 downto 0)
			);
	end component;

   --declare inputs and initialize them
   signal clk:			std_logic := '0';
   signal rst: 		std_logic := '0';

   signal desired_position : std_logic_vector(13 downto 0) := (others => '0');
   signal current_position : std_logic_vector(13 downto 0) := (others => '0');

   signal jog_left : std_logic := '0';
   signal jog_right : std_logic := '0';

   signal dir : std_logic := '0';
   signal shortest_path : std_logic := '0';

   signal mode : std_logic := '0';
	
   --declare outputs and initialize them
   signal m_move : std_logic := '0';
   signal m_dir : std_logic := '0';

   signal pos_error : std_logic_vector(14 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 100 us;
	
begin
    -- Instantiate the Unit Under Test (UUT)
   uut: stepper_controller port map (
								clk => clk,
								rst => rst,
								
								desired_position => desired_position,
								current_position => current_position,

								jog_left => jog_left,
								jog_right => jog_right,

								dir => dir,
								shortest_path => shortest_path,

								mode=>mode,
								
								m_move => m_move,
								m_dir => m_dir,
								
								pos_error => pos_error
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

		desired_position <= (others => '0');
		current_position <= (others => '0');
		
		-- test jog mode
		for i in 0 to 1 loop
			if i = 0 then
				mode <= '0';
			else
				mode <= '1';
			end if;
			
			jog_left <= '1';
			wait for clk_period * 2;
			jog_left <= '0';
			wait for clk_period * 2;
			jog_right <= '1';
			wait for clk_period * 2;
			jog_right <= '0';
			wait for clk_period * 2;
			jog_left <= '1';
			jog_right <= '1';
			wait for clk_period * 2;
			jog_left <= '0';
			jog_right <= '0';
			wait for clk_period * 2;
		end loop;

		-- test positioning mode
		mode <= '1';
		for i in 0 to 3 loop
			case i is
				when 0 => dir <= '0'; shortest_path <= '0';
				when 1 => dir <= '1'; shortest_path <= '0';
				when 2 => dir <= '0'; shortest_path <= '1';
				when 3 => dir <= '1'; shortest_path <= '1';
			end case;

			desired_position <= (2 downto 0 => '1', others => '0');
			current_position <= (others => '0');
			wait for clk_period * 2;
			mode <= '0';
			wait for clk_period * 2;
			mode <= '1';
			wait for clk_period * 2;
			desired_position <= (others => '0');
			wait for clk_period * 2;
		end loop;
		
		mode <= '1';
		for i in 0 to 3 loop
			case i is
				when 0 => dir <= '0'; shortest_path <= '0';
				when 1 => dir <= '1'; shortest_path <= '0';
				when 2 => dir <= '0'; shortest_path <= '1';
				when 3 => dir <= '1'; shortest_path <= '1';
			end case;
			
			desired_position <= (2 downto 0 => '1', others => '0');
			current_position <= (others => '0');
			wait for clk_period * 2;
			current_position <= (2 downto 0 => '1', others => '0');
			wait for clk_period * 2;
			desired_position <= (others => '0');
			wait for clk_period * 2;
			current_position <= (others => '0');
			wait for clk_period * 2;
		end loop;

		assert false report "end of simulation" severity failure;
			  
		wait;
		
  end process;
end;