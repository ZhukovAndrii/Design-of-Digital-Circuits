library ieee;
use ieee.std_logic_1164.all;
use work.all;
use WORK.globals.all;

entity  keyboard_shift_display  is
	port (
		clock: in std_logic;
		ps2_clk: in std_logic;
		ps2_data: in std_logic;
		reset: in std_logic;
		sseg_disp_0: out std_logic_vector(6 downto 0);
		sseg_disp_1: out std_logic_vector(6 downto 0);
		sseg_disp_2: out std_logic_vector(6 downto 0);
		sseg_disp_3: out std_logic_vector(6 downto 0));
end  keyboard_shift_display ;

architecture behav of  keyboard_shift_display is
	signal reset_s: std_logic;
	signal keytrigger: std_logic;
	signal char_code: std_logic_vector (7 downto 0);
	signal ready: std_logic;
	signal keydigit: std_logic_vector (3 downto 0);
	signal keyevent: key_event_type;
	signal code: std_logic_vector (15 downto 0);
	
begin		
		reset_s <= not reset;
		p1: entity work.keyboard(behav) -- compute the char_code
			port map (
				clock => clock,
				reset => reset_s,
				ps2_data => ps2_data,
				ps2_clk => ps2_clk,
				char_code => char_code,
				char_ready => ready
			);
		p2: entity work.scancode_decoder(behav) -- decode the charcode
			port map (
				clock => clock,
				char_code => char_code,
				char_ready => ready,
				reset => reset_s,
				keydigit => keydigit,
				keyevent => keyevent,
				keytrigger => keytrigger
			);
		p4: entity work.dec_shift_reg(behav) --store the value 
		generic map(WIDTH => 16)
			port map (
				clock => clock,
				reset => reset_s,
				digit => keydigit,
				trigger => keytrigger,
				max => "0010011100001111",
				Q => code
			);
		p5: entity work.dec16_to_7seg(behav) --show the value
			port map (
				input => code,
				output1 => sseg_disp_3,
				output2 => sseg_disp_2, 
				output3 => sseg_disp_1, 
				output4 => sseg_disp_0
			);
		
end architecture behav;
