library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity seven_seg_display is
port (
  clock: in std_logic;
  reset: in std_logic;
  trigger: in std_logic;
  input : in std_logic_vector(3 downto 0);
  output : out std_logic_vector(6 downto 0)
);
end seven_seg_display;

architecture behav of seven_seg_display is --------- Almost same as led_display
  signal reset_s, trigger_s, enable_s: std_logic;  
  signal bcd_input: std_logic_vector(3 downto 0);

begin
  reset_s <= not reset; ---------------------------- negative logic
  trigger_s <= not trigger; ------------------------ negative logic

  U1: entity work.oneshot(behav) ------------------- port map oneshot
  port map (clock => clock,
         reset => reset_s,
			pulse_o => enable_s,
         trigger_i => trigger_s);
			
  U2: entity work.reg(behav) ----------------------- port map reg
  generic map (WIDTH => 4)
  port map (clock => clock, 
         reset => reset_s,
         enable => enable_s,
         d => input, 
         q => bcd_input);
			
  U3: entity work.bcd_to_7seg(behav) --------------- port map bcd_to_7seg
  port map(input => bcd_input,
        output => output);

end architecture behav;