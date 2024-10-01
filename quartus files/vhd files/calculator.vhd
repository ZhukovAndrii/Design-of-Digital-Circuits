library ieee;
use ieee.std_logic_1164.all;
use work.all;
use WORK.globals.all;

entity  calculator  is
	port (
		clock: in std_logic;
		ps2_clk: in std_logic;
		ps2_data: in std_logic;
		reset: in std_logic;
		sseg_disp_0: out std_logic_vector(6 downto 0); --seven segment displays
		sseg_disp_1: out std_logic_vector(6 downto 0);
		sseg_disp_2: out std_logic_vector(6 downto 0);
		sseg_disp_3: out std_logic_vector(6 downto 0);
		sseg_disp_4: out std_logic_vector(6 downto 0);
		sseg_disp_5: out std_logic_vector(6 downto 0);
		sseg_disp_6: out std_logic_vector(6 downto 0);
		sseg_disp_7: out std_logic_vector(6 downto 0)
	);
end entity calculator;

architecture behav of  calculator is
	signal reset_s: std_logic;
	signal keytrigger: std_logic;
	signal char_code: std_logic_vector (7 downto 0);
	signal char_ready: std_logic;
	signal keydigit: std_logic_vector (3 downto 0);
	signal keyevent: key_event_type;
	signal operator: operator_type;
	signal keytrigger_short: std_logic;
	signal operand1, operand2: std_logic_vector (7 downto 0);
	signal result: std_logic_vector (15 downto 0);
	signal state_out: std_logic_vector (2 downto 0);
	
begin		
		reset_s <= not reset; -- negative logic
		p1: entity work.keyboard(behav) -- compute the char_code
			port map (
				clock => clock,
				reset => reset_s,
				ps2_data => ps2_data,
				ps2_clk => ps2_clk,
				char_code => char_code,
				char_ready => char_ready
			);
		p2: entity work.scancode_decoder(behav) -- decode the charcode
			port map (
				clock => clock,
				char_code => char_code,
				char_ready => char_ready,
				reset => reset_s,
				keydigit => keydigit,
				keyevent => keyevent,
				keytrigger => keytrigger
			);
		p4: entity work.central_logic(behav)
			port map(
				clock => clock,
				reset => reset_s,
				keydigit => keydigit,
				keyevent => keyevent,
				keytrigger => keytrigger,
				operator => operator,
				operand1 => operand1,
				operand2 => operand2,
				result => result
			);
		
		result_s: entity work.dec16_to_7seg(behav) --show the result
			port map (
				input => result,
				output1 => sseg_disp_3,
				output2 => sseg_disp_2, 
				output3 => sseg_disp_1, 
				output4 => sseg_disp_0
			);
		operand_1: entity work.dec8_to_7seg(behav) -- swon the operands
			port map (
				input => operand1,
				output1 => sseg_disp_7,
				output2 => sseg_disp_6
			);
		operand_2: entity work.dec8_to_7seg(behav)
			port map (
				input => operand2,
				output1 => sseg_disp_5,
				output2 => sseg_disp_4
			);
		
end architecture behav;
