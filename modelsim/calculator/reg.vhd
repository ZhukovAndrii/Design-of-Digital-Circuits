library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
  generic (
    Width : integer := 4  -------------------------------------------------- Change this value to set the number of bits in the register
  );
  Port ( 
    clock : in  std_logic; ------------------------------------------------- Clock input
    reset : in  std_logic; ------------------------------------------------- Reset input
    enable : in std_logic; ------------------------------------------------- Enable input
    d : in  std_logic_vector(Width-1 downto 0); ---------------------------- Data input
    q : out std_logic_vector(Width-1 downto 0)); --------------------------- Data output
end reg;

architecture behav of reg is
  signal reg : std_logic_vector(Width-1 downto 0) := (others => '0');------- Register signal
begin
  process (clock, reset)
  begin
    if reset = '1' then
      reg <= (others => '0'); ---------------------------------------------- Reset the register to all zeros
    elsif rising_edge(clock) then
        if enable = '1' then
            reg <= d; ------------------------------------------------------ Load the input data on rising edge of the clock
        end if;
    end if;
  end process;

  q <= reg; ---------------------------------------------------------------- Output the data from the register
end behav;