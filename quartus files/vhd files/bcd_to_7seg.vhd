library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity bcd_to_7seg is
port (

  input : in std_logic_vector(3 downto 0);
  output : out std_logic_vector(6 downto 0) ----------------- The output to the HEXes
  
);

end bcd_to_7seg;

architecture behav of bcd_to_7seg is
signal output_s: std_logic_vector(6 downto 0) := "0000000";-- The initial value of the output (negated)

  begin
  
		with input select ------------------------------------- The magic values that make HExes show numbers
			output_s <= "0111111" when "0000",
			"0000110" when "0001",
			"1011011" when "0010",
			"1001111" when "0011",
			"1100110" when "0100",
			"1101101" when "0101",
			"1111101" when "0110",
			"0000111" when "0111",
			"1111111" when "1000",
			"1101111" when "1001",
			"0000000" when others;
	
		output <= not output_s; ------------------------------- negative logic

end architecture behav;