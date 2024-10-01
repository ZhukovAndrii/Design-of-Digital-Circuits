library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vga_ctrl is
	port(
		clk_25Mhz : in std_logic;                     -- VGA clock 
		red, green, blue : in std_logic;              -- only one bit per color (in)
		red_out, green_out, blue_out : out std_logic; -- only one bit per color (out)
		hsync_out, vsync_out : out std_logic;         -- horiztontal and vertical sync signals
		video_blank : buffer std_logic;               -- blank (disable) VGA output (active low!)
		pixel_row, pixel_col : out	std_logic_vector(9 DOWNTO 0)  -- current pixel row and column
	);
end entity vga_ctrl;


architecture vga_ctrl_arch of vga_ctrl is
	signal hsync, vsync : std_logic;  -- horizontal and vertical sync signals
	signal hcount : std_logic_vector(9 DOWNTO 0);  -- horizontal pixel count (in row)
	signal vcount : std_logic_vector(9 DOWNTO 0);  -- row count

	signal hblank, vblank : std_logic; -- horizontal and vertical blanking (active low!)

	-- constants for horizontal timing
	constant hpixels_visible : integer := 640;
	constant hsync_low : integer       := 664;
	constant hsync_high : integer      := 760;
	constant hend : integer            := 800;
	
	-- constants for vertical timing
	constant vpixels_visible : integer := 480;
	constant vsync_low : integer       := 491;
	constant vsync_high : integer      := 493;
	constant vend : integer            := 525;

begin

	video_blank <= hblank AND vblank;  -- video blank is active (i.e. low) if hblank or vblank (or both) are active

	process (clk_25Mhz)
	begin
		if (rising_edge(clk_25Mhz)) then
	
			-- horizontal timing:
			-- hsync is low for between hsync_low and hsync_high
			-- hsync  ------------------------------------__________--------
			-- hcount 0                 #pixels            sync low      end
		
			-- count horizontal pixels
			if (hcount = hend) then
				hcount <= (others => '0');
			else
				hcount <= hcount + 1;
			end if;

			-- generate hsync signal
			if ((hcount >= hsync_low) AND (hcount <= hsync_high)) then
				hsync <= '0';
			else
				hsync <= '1';
			end if;

			
			
			-- vertical timing:
			-- vsync is low between vsync_low and vsync_high
			-- vsync  -----------------------------------------------_______------------
			-- vcount 0                        last pixel row      V sync low       end

			-- count rows
			if ((vcount >= vend) AND (hcount >= hsync_low)) then
				vcount <= (others => '0');
			elsif (hcount = hsync_low) then
				vcount <= vcount + 1;
			end if;

			-- generate vsync
			if (vcount <= vsync_high) AND (vcount >= vsync_low) then
				vsync <= '0';
			else
				vsync <= '1';
			end if;

		
		
			--- horizontal and vertical blanking:
			
			-- generate horizontal blank signal (hblank)
			-- hblank is active low - i.e. hblank = 0 means blank is enabled
			if (hcount < hpixels_visible) then
				hblank <= '1';
				pixel_col <= hcount;
			else
				hblank <= '0';
			end if;

			-- generate vertical blank signal (vblank)
			-- vblank is active low - i.e. vblank = 0 means blank is enabled
			if (vcount <= vpixels_visible) then
				vblank <= '1';
				pixel_row <= vcount;
			else
				vblank <= '0';
			end if;


			-- creates flip flops for outputs (to avoid glitches)
			hsync_out 	<= hsync;
			vsync_out 	<= vsync;
			red_out 	<= red AND video_blank;  -- note: video blank is 1 when pixels should be displayed (i.e., no blanking)
			green_out   <= green AND video_blank;
			blue_out 	<= blue AND video_blank;

		end if; -- rising_edgbe(clk_25Mhz)
	end process;
end architecture vga_ctrl_arch;
