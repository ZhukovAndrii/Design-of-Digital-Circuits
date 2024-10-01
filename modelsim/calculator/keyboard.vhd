library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keyboard is
    Port (
        clock : in STD_LOGIC; 
        reset : in STD_LOGIC; 
        ps2_clk : in STD_LOGIC; 
        ps2_data: in STD_LOGIC; --- the input from the keyboard
        char_code: out STD_LOGIC_VECTOR(7 downto 0);
        char_ready: out STD_LOGIC
    );
end entity keyboard;

architecture behav of keyboard is
  type state_type is (IDLE, DATA, PARITY, STOP);
  signal char_code_s, next_char_code_s: std_logic_vector (7 downto 0); -- stored and next output code
  signal pulse_s: std_logic;  -------------- synchronised ps2_clk
  signal parity_bit, next_parity_bit: std_logic; ----- stored and next expected parity bit
  signal ready, next_ready: std_logic;   
  signal state, next_state: state_type:= IDLE;  --- stored and next state
  signal counter, next_counter: integer;  ------ the counter for data state
begin
  
  U1: entity work.oneshot(behav)   ---- first we synchronise ps2_clk by oneshot
    port map(
      reset => reset,
      clock => clock,
      trigger_i => ps2_clk,
      pulse_o => pulse_s
    );
    
  storage_proc: process(clock, reset) is  --- the storage process (changes the state too)
    begin
      if (reset = '1') then  -------- initializing
        char_code_s <= "00000000";
        state <= IDLE;
        parity_bit <= '0';
        ready <= '0';
        counter <= 1;
      elsif rising_edge(clock) then  --- we only change the state on the rising edge of the system clock
        state <= next_state;
        counter <= next_counter;
        parity_bit <= next_parity_bit;
        ready <= next_ready;
        char_code_s <= next_char_code_s;
      end if;
end process storage_proc;
      
      
  next_state_proc: process(pulse_s, ps2_data, state, counter, parity_bit, char_code_s, ready) is
    begin  ---- here is our state machine 
      next_parity_bit <= parity_bit;  --- initializing next_... signals
	    next_state <= state;
	    next_counter <= counter;
	    next_char_code_s <= char_code_s;
	    next_ready <= ready;
	
      if (pulse_s = '1') then  --- we only change the state when the ps2_clk is on the rising edge
        case state is 
          when IDLE =>  --- the initial state
            next_char_code_s <= "00000000";
            next_parity_bit <= '0';
            next_counter <= 1;
            next_ready <= '0';
            if ps2_data = '1' then 
              next_state <= IDLE;
            else  -- start of transmission
              next_state <= DATA;
            end if;
          when DATA =>     ---- in this state we receive data from the keyboard
            next_char_code_s <=  ps2_data & char_code_s(7 downto 1);
            next_parity_bit <= parity_bit xor ps2_data; 
            if (counter = 8) then  -- all the 8 data bits are stored
              next_state <= PARITY;
            else
              next_state <= DATA;
              next_counter <= counter + 1; -- increment the counter
            end if;
          when PARITY =>  -- now we check if our expected parity bit is actually equal to the given one
            next_parity_bit <= parity_bit xor ps2_data;
            next_state <= STOP;
            next_ready <= '1';
          when STOP => -- in this state we assign the current code to the char_code output
            next_state <= IDLE;
        end case;
      end if;
    end process next_state_proc;
          
    char_code <= char_code_s;
    char_ready <= '1' when (parity_bit = '1' and state = STOP)  --- if the parity_bit was valid though
                    else '0';
  
end behav;