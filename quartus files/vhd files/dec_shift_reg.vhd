library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.all;

entity dec_shift_reg is

generic (WIDTH: integer);
port (

	clock: in std_logic;
	reset: in std_logic;
	trigger: in std_logic;
	digit: in std_logic_vector(3 downto 0);
	max: in std_logic_vector(WIDTH-1 downto 0);
	Q: out std_logic_vector(WIDTH-1 downto 0)
	
);
end entity dec_shift_reg;

architecture behav of dec_shift_reg is

	signal overflow, enable_s: std_logic;
	signal next_value: std_logic_vector(WIDTH+3 downto 0);
	signal output_s: std_logic_vector(WIDTH-1 downto 0);   --signal for output from register

begin
   -- next_value = output*10 && digit
	next_value <= conv_std_logic_vector(conv_integer(unsigned(output_s))*10 + conv_integer(unsigned(digit)),WIDTH+4);
	-- overflow if next_value > max or digit > 9
	overflow <= '1' when (next_value > ("0000" & max)) or (digit > "1001") else '0';
	-- only works if not overflow
	enable_s <= (not overflow) and trigger;
	
	Q <= output_s; -- the output is the stored value

U1: entity work.reg(behav) -- port map egister
generic map (WIDTH => WIDTH)
port map (clock => clock,
			 reset => reset, 
			 enable => enable_s,
			 d => next_value(WIDTH-1 downto 0),
			 q => output_s);

end architecture behav;