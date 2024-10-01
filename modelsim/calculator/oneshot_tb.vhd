library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity oneshot_tb is
end oneshot_tb;

architecture behav of oneshot_tb is

	signal trigger_tb: std_logic; 
	signal clock_tb: std_logic;
	signal pulse_o_tb: std_logic;  
	signal reset_tb: std_logic;

begin

	r: process
	begin 
		reset_tb <= '1';
		wait for 5 ns;
		reset_tb <= '0';
		wait;
	end process r;

	e: process
	begin
		trigger_tb <= '0';
		wait for 20 ns;
		trigger_tb <= '1';
		wait for 38 ns;
		trigger_tb <= '0';
		wait for 20 ns;
		trigger_tb <= '1';
		wait for 50 ns;
		trigger_tb <= '0';
		wait for 22 ns;
		trigger_tb <= '1';
		wait for 10 ns;
		trigger_tb <= '0';
		wait;
	end process e;

	c: process
	begin 
		clock_tb <= '1';
		wait for 5 ns;
		clock_tb <= '0';
		wait for 5 ns;
	end process c;

	Mapping: entity oneshot(behav)
	port map (
		clock => clock_tb,
		trigger_i => trigger_tb,
		reset => reset_tb,
		pulse_o => pulse_o_tb);

end architecture behav;
