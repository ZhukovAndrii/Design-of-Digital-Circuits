library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

entity keyboard_tb is
end keyboard_tb;

architecture behav of keyboard_tb is

	signal clock_tb, reset_tb, ps2_clk_tb, ps2_data_tb, char_ready_tb:  std_logic;
	signal char_code_tb: std_logic_vector (7 downto 0);

begin
	
	c: process
	begin 
		--50Mhz
		clock_tb <= '1';
		wait for 20 ns;
		clock_tb <= '0';
		wait for 20 ns;
	end process c;

	r: process
	begin 
		reset_tb <= '1';
		wait for 50 us;
		reset_tb <= '0';
		wait;
	end process r;

	ps2_c:process
	begin 
		--- 16,7 khz
		ps2_clk_tb <= '1';
		wait for 30 us;
		ps2_clk_tb <= '0';
		wait for 30 us;
		ps2_clk_tb <= '1';
		wait for 30 us;
		ps2_clk_tb <= '0';
		wait for 30 us;
	end process ps2_c;

	ps2_d2: process
	begin
		--LSBs first!

		ps2_data_tb <= '1';
		wait for 180 us;

		-- start data
		ps2_data_tb <= '0';
		wait for 60 us;
		
		-- 0xF0 = 11110000 = break code
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '1';
		-- parity
		wait for 60 us;
		ps2_data_tb <= '1';
		
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '1';
		
		-- start data
		ps2_data_tb <= '0';
		wait for 60 us;

		-- 0x16 = 00010110 = key "1"
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '1';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '0';
		wait for 60 us;
		ps2_data_tb <= '0';
		-- parity
		wait for 60 us;
		ps2_data_tb <= '1';
		
		wait for 60 us;
		ps2_data_tb <= '1';
		wait;
		

	end process ps2_d2;

	Mapping: entity keyboard(behav)
	port map (
		clock => clock_tb,
		reset => reset_tb,
		ps2_clk => ps2_clk_tb,
		ps2_data => ps2_data_tb,
		char_code => char_code_tb,
		char_ready => char_ready_tb);

end architecture behav;

