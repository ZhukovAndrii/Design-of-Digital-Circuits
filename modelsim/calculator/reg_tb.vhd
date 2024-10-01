library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity reg_tb is
end reg_tb;

architecture behav of reg_tb is

	constant vector_width: integer := 8;

	signal input_tb: std_logic_vector(vector_width-1 downto 0); 
	signal output_tb: std_logic_vector(vector_width-1 downto 0); 
	signal clock_tb: std_logic;
	signal enable_tb: std_logic;  
	signal reset_tb: std_logic;

begin

	r: process
	begin 
		reset_tb <= '1';
		wait for 5 ns;
		reset_tb <= '0';
		wait for 70 ns;
		reset_tb <= '1';
		wait for 10 ns;
		reset_tb <= '0';
		wait;
	end process r;

	e: process
	begin
		enable_tb <= '0';
		wait for 10 ns;
		enable_tb <= '1';
		wait;
	end process e;

	c: process
	begin 
		clock_tb <= '1';
		wait for 5 ns;
		clock_tb <= '0';
		wait for 5 ns;
	end process c;

	d: process
	begin 
		input_tb<="00000001";
		wait for 10 ns;
		input_tb<="00010100";
		wait for 10 ns;
		input_tb<="00100000";
		wait for 30 ns;
		input_tb<="00000000";
		wait for 10 ns;
		input_tb<="01000000";
		wait;
	end process d;

	Mapping: entity reg(behav)
	generic map (WIDTH => vector_width)
	port map (
		D => input_tb,
		Q => output_tb,
		clock => clock_tb,
		enable => enable_tb,
		reset => reset_tb);

end architecture behav;


