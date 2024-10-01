library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity seven_seg_16_display is -- pretty same as seven_seg_display
port (
  clock: in std_logic;
  reset: in std_logic;
  trigger: in std_logic;
  input : in std_logic_vector(15 downto 0);
  output1 : out std_logic_vector(6 downto 0); ---- HEXes
  output2 : out std_logic_vector(6 downto 0);
  output3 : out std_logic_vector(6 downto 0);
  output4 : out std_logic_vector(6 downto 0)
);
end seven_seg_16_display;

architecture behav of seven_seg_16_display is
  signal reset_s, trigger_s, enable_s: std_logic;
  signal bcd_input: std_logic_vector(15 downto 0);
  constant WIDTH: integer:= 16; ------------------ constant WIDTH

	begin
		reset_s <= not reset; ---------------------- negative logic
		trigger_s <= not trigger; ------------------ negative logic

		U1: entity work.oneshot(behav) ------------- port map oneshot
		port map (clock => clock,
			reset => reset_s,
			pulse_o => enable_s,
         trigger_i => trigger_s);
		U2: entity work.reg(behav) ----------------- port map register
		generic map (WIDTH => WIDTH)
		port map (clock => clock, 
			reset => reset_s,
         enable => enable_s,
         d => input, 
         q => bcd_input);
		U4: entity work.dec16_to_7seg(behav) ------- decode for HEXes
		port map(input => bcd_input,
			output1 => output1,
			output2 => output2,
			output3 => output3,
			output4 => output4);
end architecture behav;