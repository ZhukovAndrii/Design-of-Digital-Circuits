library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.globals.all;

entity vga_top is
	PORT(
		signal operand1, operand2 : in std_logic_vector(7 downto 0);
		signal result : in std_logic_vector(15 downto 0);
		signal operator : in operator_type;
		
		signal clk_50Mhz : in std_logic;
		signal vga_red : out std_logic_vector(9 downto 0);
		signal hsync, vsync	: out STD_LOGIC; 
		signal video_blank : out std_logic;
		signal pixel_clock : buffer std_logic
		);
end entity vga_top;


architecture vga_top_arch of vga_top is
		signal clk_25Mhz : std_logic; -- VGA clock signal derived from sys_clk (50MHz) via PLL

		signal q : std_logic_vector(7 downto 0);
		signal address : std_logic_vector(5 DOWNTO 0);
		signal red, green, blue	: std_logic;
		signal red_out, green_out, blue_out : std_logic;
		signal pixel_row, pixel_col : std_logic_vector(9 downto 0);
begin
	-- font rom controller instance
	FR : WORK.font_rom_ctrl(font_rom_ctrl_arch) port map(
		pixel_clock, 
		address, 
		pixel_row(2 downto 0),
		pixel_col(2 downto 0),
		red
	);

	-- vga clock pll instance
	VGA_CLK: WORK.vga_pll port map (
		inclk0	=> clk_50Mhz, 
		c0 => clk_25Mhz
	);
	pixel_clock <= clk_25Mhz;
	
	-- vga controller
	VGA : WORK.vga_ctrl(vga_ctrl_arch) port map (
		clk_25Mhz, -- vga clock
		red,       -- input pixels (1 bit each only)
		green, 
		blue, 
		red_out,   -- output pixels (1 bit each only)
		green_out, 
		blue_out, 
		hsync,     -- horizontal sync singal (out)
		vsync,     -- vertical sync singal (out)
		video_blank,  -- video blanking
		pixel_row, -- current pixel row
		pixel_col  -- current pixel col
	);

	-- boost one bit red value to 10bit (sent to the DAC)
	vga_red <= "1111111111" when red = '1' else "0000000000";
	


	--------------
	process(pixel_row, pixel_col)
	
			function numDecode(num : integer) return std_logic_vector is --std_logic_vector(5 downto 0) is
				variable address : integer;
			begin
				case (num) is
					when 0 => address := 8#60#;
					when 1 => address := 8#61#;
					when 2 => address := 8#62#;
					when 3 => address := 8#63#;
					when 4 => address := 8#64#;
					when 5 => address := 8#65#;
					when 6 => address := 8#66#;
					when 7 => address := 8#67#;
					when 8 => address := 8#70#;
					when 9 => address := 8#71#;
					when others => address := 8#41#;
				end case;
				return conv_std_logic_vector(address, 6);
			end;
	
	
	begin
		address <= std_logic_vector(conv_unsigned(8#40#, 6));  -- space


		-- Note: The following code for displaying is very... crude.
		--       If there is time the code should be replaced with a more clean version.
		if (CONV_INTEGER(UNSIGNED(pixel_row)) < 8) then
		
			-- operand 1
			if (CONV_INTEGER(UNSIGNED(pixel_col)) < 8) then
				address <= numDecode((conv_integer(unsigned(operand1)) / 100) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 8 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 16) then
				address <= numDecode((conv_integer(unsigned(operand1)) / 10) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 16 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 24) then
				address <= numDecode(conv_integer(unsigned(operand1)) mod 10);

			-- operator
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 24 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 32) then
				address <= std_logic_vector(conv_unsigned(8#40#, 6));
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 32 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 40) then
				case (operator) is
					when UNDEF => address <= conv_std_logic_vector(8#40#, 6); -- +
					when ADD => address <= conv_std_logic_vector(8#53#, 6); -- +
					when SUB => address <= conv_std_logic_vector(8#55#, 6); -- -
					when MUL => address <= conv_std_logic_vector(8#52#, 6); -- * 
					when DIV => address <= conv_std_logic_vector(8#57#, 6); -- * 
					when others => address <= conv_std_logic_vector(8#05#, 6); -- E
				end case;
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 40 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 48) then
				address <= std_logic_vector(conv_unsigned(8#40#, 6));
				
			-- operand 2
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 48 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 56) then
				address <= numDecode((conv_integer(unsigned(operand2)) / 100) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 56 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 64) then
				address <= numDecode((conv_integer(unsigned(operand2)) / 10) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 64 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 72) then
				address <= numDecode(conv_integer(unsigned(operand2)) mod 10);
				
			-- equal sign
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 72 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 80) then
				address <= std_logic_vector(conv_unsigned(8#40#, 6));
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 80 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 88) then
				address <= std_logic_vector(conv_unsigned(8#54#, 6));
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 88 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 96) then
				address <= std_logic_vector(conv_unsigned(8#40#, 6));

			-- result
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 96 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 104) then
				address <= numDecode((conv_integer(unsigned(result)) / 1000) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 104 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 112) then
				address <= numDecode((conv_integer(unsigned(result)) / 100) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 112 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 120) then
				address <= numDecode((conv_integer(unsigned(result)) / 10) mod 10);
			elsif (CONV_INTEGER(UNSIGNED(pixel_col)) >= 120 AND CONV_INTEGER(UNSIGNED(pixel_col)) < 128) then
				address <= numDecode(conv_integer(unsigned(result)) mod 10);
				
			end if;
		end if;	end process;

end architecture vga_top_arch;