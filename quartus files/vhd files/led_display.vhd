library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity led_display is
port (
  clock: in std_logic;
  reset: in std_logic;
  trigger: in std_logic;
  input : in std_logic_vector(3 downto 0); --------- Input from the board
  output : out std_logic_vector(3 downto 0) -------- Ouput to the LEDs
  
);

end led_display;

architecture behav of led_display is
  signal reset_s, trigger_s: std_logic; -- signals for negative logic
  signal enable_s: std_logic; ------------ goes from oneshot to the reg

begin

  reset_s <= not reset; ------------------ negative logic
  trigger_s <= not trigger; -------------- negative logic

  U1: entity work.oneshot(behav) --------- connection to oneshot
  port map (clock => clock,
         reset => reset_s,
			pulse_o => enable_s, ------------ the enable_s will be conected to the register
         trigger_i => trigger_s);
			
  U2: entity work.reg(behav) ------------- connection to the register
  generic map (WIDTH => 4) --------------- we only need 4 bits to store
  port map (clock => clock,
         reset => reset_s,
         enable => enable_s, ------------- enable_s = pusle and connected to the enable
         d => input, 
         q => output); ------------------- the output is stored in the register value

end architecture behav;