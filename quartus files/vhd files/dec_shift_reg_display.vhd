library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.all;

entity dec_shift_reg_display is
	port (
		clock: in std_logic;
		reset: in std_logic;
		trigger: in std_logic;
		input : in std_logic_vector(3 downto 0);
		output1, output2, output3, output4 : out std_logic_vector(6 downto 0)
	);
end entity dec_shift_reg_display;

architecture behav of dec_shift_reg_display is
	constant WIDTH: integer:= 16;
	signal reset_s, trigger_s, enable_s: std_logic;
	signal output_s: std_logic_vector(WIDTH-1 downto 0); -- signal for output from register
	signal output_s1, output_s2, output_s3, output_s4: std_logic_vector(6 downto 0);
	signal max_s: std_logic_vector(WIDTH-1 downto 0); ----- the maximal stored valur (9999)

	begin
		reset_s <= not reset; ------------------------------ negative logic
		trigger_s <= not trigger; -------------------------- negative logic
		max_s <= "0010011100001111"; ----------------------- 9999 in decimal
		
		output1 <= output_s1;
		output2 <= output_s2;
		output3 <= output_s3;
		output4 <= output_s4;

		U1: entity work.oneshot(behav) -------------------- port map oneshot
			port map (clock => clock,
						 reset => reset_s,
						 trigger_i => trigger_s,
						 pulse_o => enable_s);
						 
		U2: entity work.dec_shift_reg(behav) -------------- port map register
			generic map (WIDTH => WIDTH)
			port map (clock => clock,
						 reset => reset_s,
						 trigger => enable_s, 
						 digit => input,
						 max => max_s,
						 Q => output_s);
						 
				U3: entity work.dec16_to_7seg(behav) -------------- decode
			port map (input => output_s,
						 output1 => output_s1,
						 output2 => output_s2,
						 output3 => output_s3,
						 output4 => output_s4);		
		
end architecture behav;
