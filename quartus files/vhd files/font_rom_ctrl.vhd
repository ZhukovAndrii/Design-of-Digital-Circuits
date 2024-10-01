library ieee;
use  ieee.std_logic_1164.all;
use  ieee.std_logic_arith.all;
use  ieee.std_logic_unsigned.all;


entity font_rom_ctrl is
	port(
		clk : in std_logic;
		char_idx : in std_logic_vector(5 downto 0);  -- we have 64 chars in the ROM
		char_row : in std_logic_vector(2 downto 0);  -- each char has 8 rows
		char_col : in std_logic_vector(2 downto 0);  -- each char has 8 cols
		char_pixel : out std_logic
	);
end entity font_rom_ctrl;

--

architecture font_rom_ctrl_arch of font_rom_ctrl is
	signal char_data : std_logic_vector(7 downto 0);
	signal char_addr : std_logic_vector(8 downto 0);
begin

	-- the ROM address is determined by the character address plus the row offset
	-- char_addr is shiftes to the left by 3 bits (equiv. to multiplication by 8)
	char_addr <= char_idx & char_row;
	
	FR : WORK.font_rom port map (
		address	 => char_addr,
		clock	 => clk,
		q	     => char_data
	);

	-- select output pixel from current line
	char_pixel <= char_data((8 - CONV_INTEGER(char_col(2 downto 0))));
end architecture font_rom_ctrl_arch;


