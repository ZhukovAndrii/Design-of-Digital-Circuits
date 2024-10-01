library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dec16_to_7seg is -------------------------- extention of the dec8_to_7seg for 4 decimals
port (
  input : in std_logic_vector(15 downto 0);
  output1 : out std_logic_vector(6 downto 0);
  output2 : out std_logic_vector(6 downto 0);
  output3 : out std_logic_vector(6 downto 0);
  output4 : out std_logic_vector(6 downto 0)
);
end dec16_to_7seg;

architecture behav of dec16_to_7seg is
	signal output_s1: std_logic_vector(6 downto 0) := "0000000";
	signal output_s2: std_logic_vector(6 downto 0) := "0000000";
	signal output_s3: std_logic_vector(6 downto 0) := "0000000";
	signal output_s4: std_logic_vector(6 downto 0) := "0000000";
	signal int: integer := to_integer(unsigned(input));
	signal int1, int2: integer;
	signal out1: std_logic_vector(7 downto 0);
	signal out2: std_logic_vector(7 downto 0);

  begin
	int1 <= int / 100;
	int2 <= int mod 100;
	out1 <= std_logic_vector(to_unsigned(int1, 8));
	out2 <= std_logic_vector(to_unsigned(int2, 8));
  
   U1: entity work.dec8_to_7seg(behav)
	port map(input => out1,
	          output1 => output_s1,
				 output2 => output_s2);
	U2: entity work.dec8_to_7seg(behav)
	port map(input => out2,
	          output1 => output_s3,
				 output2 => output_s4);
				
	output1 <= output_s1;
	output2 <= output_s2;
	output3 <= output_s3;
	output4 <= output_s4;

end architecture behav;