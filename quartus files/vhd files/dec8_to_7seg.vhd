library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dec8_to_7seg is
port (
  input : in std_logic_vector(7 downto 0);
  output1 : out std_logic_vector(6 downto 0); ----------------- the first HEX
  output2 : out std_logic_vector(6 downto 0)  ----------------- the second one
);
end dec8_to_7seg;

architecture behav of dec8_to_7seg is
signal output_s1: std_logic_vector(6 downto 0) := "0000000"; -- initializing
signal output_s2: std_logic_vector(6 downto 0) := "0000000"; -- initializing
signal int: integer; ------------------------------------------ the full input
signal int1: integer := 0; ------------------------------------ the first half of the input
signal int2: integer := 0; ------------------------------------ the second one
signal out1: std_logic_vector(3 downto 0); -------------------- the first half of the output
signal out2: std_logic_vector(3 downto 0); -------------------- the second one

  begin
		int <= to_integer(unsigned(input)); --------------------- to devide the input to the 2 decimal digits
                                                             -- we convert it to integer																	 
		int1 <= int / 10; --------------------------------------- split
		int2 <= int mod 10; ------------------------------------- split
		out1 <= std_logic_vector(to_unsigned(int1, 4)); --------- convert back to binary
		out2 <= std_logic_vector(to_unsigned(int2, 4)); --------- convert too
  
		U1: entity work.bcd_to_7seg(behav) ---------------------- conversion to HEX
			port map(input => out1,
	          output => output_s1);
		U2: entity work.bcd_to_7seg(behav) ---------------------- conversion to HEX
			port map(input => out2,
	          output => output_s2);
				 
		output1 <= output_s1; ------------------------------- negative logic
		output2 <= output_s2; ------------------------------- negative logic
	

end architecture behav;