library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity keyboard_display is
	port (
		clock: in std_logic;
		ps2_clk: in std_logic;
		ps2_data: in std_logic;
		reset: in std_logic;
		output1: out std_logic_vector(6 downto 0);
		output2: out std_logic_vector(6 downto 0);
		output3: out std_logic_vector(6 downto 0);
		output4: out std_logic_vector(6 downto 0));
end keyboard_display;

architecture behav of keyboard_display is
	signal temp_data: std_logic_vector(7 downto 0);
	signal data: std_logic_vector(15 downto 0);
	signal reset_s: std_logic;
	signal ready: std_logic;
begin		

		reset_s <= not reset; -- negative logic
		
		p1: entity work.reg(behav) -- here we store the char from the keyboard
			generic map(WIDTH => 16)
			port map (
				enable => ready,
				clock => clock,
				reset => reset_s, --only works then char_ready is 1!
				d => "00000000" & temp_data,
				q => data
			);	
		p2: entity work.dec16_to_7seg(behav) -- show the code on hexes in decimals
			port map(
				input => data,
				output1 => output1,
				output2 => output2,
				output3 => output3,
				output4 => output4
			);
		p3: entity work.keyboard(behav) -- the keyboard driver
			port map (
				clock => clock,
				ps2_clk => ps2_clk,
				ps2_data => ps2_data,
				reset => reset_s,
				char_code => temp_data,
				char_ready => ready
			);
end architecture behav;

