library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use WORK.globals.all;

entity scancode_decoder is
  port(
    signal clock : in std_logic;
    signal char_code : in std_logic_vector(7 downto 0);
    signal char_ready : in std_logic;
    signal reset : in std_logic;
    signal keydigit : out std_logic_vector(3 downto 0);
    signal keyevent : out key_event_type;
    signal keytrigger : out std_logic); -- 1 is only when the num or event is transmitted
end scancode_decoder;

architecture behav of scancode_decoder is 
	-- these signal are all made for a proper work of a state machine
	type state_type is (idle, break, new_code, hold, ignore);
	signal state, next_state : state_type := idle;
	signal keyevent_s, next_keyevent_s: key_event_type := KEY_OTHER;
	signal keydigit_s, next_keydigit_s: std_logic_vector (3 downto 0) := "0000";
	signal keytrigger_s, next_keytrigger_s: std_logic := '0';
	
	begin
	storage_proc: process(clock, reset) -- the storage process
		begin 
			if reset = '1' then -- initializing
				state <= idle;
				keydigit_s <= "0000";
				keyevent_s <= KEY_OTHER;
				keytrigger_s <= '0';
			elsif rising_edge(clock) then --change the state on the rising edge of the system clock
				state <= next_state;
				keyevent_s <= next_keyevent_s;
				keydigit_s <= next_keydigit_s;
				keytrigger_s <= next_keytrigger_s;
			end if;
		end process storage_proc;
		
	next_state_proc: process (state, char_ready, char_code) -- computes the next_state and next_keytrigger_s
		begin
			if rising_edge(clock) then
			case state is
				when idle => -- trigger is always 0 at this state 
					if char_ready = '1' then
						if char_code = x"F0" then -- move to "break" state if a break char is given
							next_state <= break;
						elsif keyevent_s = KEY_NUM then  -- move to "new_code" state if a key_num is pressed
							next_keytrigger_s <= '1';
							next_state <= new_code;
						end if;
					end if;
				when break => -- we are supposed to skip this "break" char and the next one
					if char_ready = '0' then
						next_state <= hold;
					end if;
				when hold =>  -- wait for the next char which we also skip
					if char_ready = '1' then
						next_state <= ignore;
					end if;
				when ignore => -- ignore this char 
					if char_ready = '0' then
						next_state <= idle; -- and go back to the idle state
					end if;
				when new_code => -- wait while the key is transmitted
					next_keytrigger_s <= '0'; -- we oneed keytrigger to be 1 for only 1 clock cycle
					if char_ready = '0' then
						next_state <= idle; --when the character is over go to the idle state
					end if;	
			end case;
			end if;
		end process next_state_proc;
		
	scancode_proc : process(char_code) is --compute the next_keyevent and next_keydigit
    begin -- we change it as soon as the char_code is changed no matte rwhat happens 
			 -- as these keydigit and keyevent are only read when the keytrigger is 1 
			next_keydigit_s <= "0000";
			next_keyevent_s <= KEY_OTHER;
	
         case char_code is
                when x"70" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0000"; 
                when x"69" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0001"; 
                when x"72" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0010"; 
                when x"7A" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0011"; 
                when x"6B" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0100"; 
                when x"73" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0101"; 
                when x"74" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0110"; 
                when x"6C" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "0111"; 
                when x"75" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "1000"; 
                when x"7D" => next_keyevent_s <= KEY_NUM; next_keydigit_s <= "1001"; 
					 when x"4A" => next_keyevent_s <= KEY_DIV; 
                when x"7C" => next_keyevent_s <= KEY_MUL; 
                when x"7B" => next_keyevent_s <= KEY_SUB; 
                when x"79" => next_keyevent_s <= KEY_ADD; 
                when x"5A" => next_keyevent_s <= KEY_ENTER; 
                when x"76" => next_keyevent_s <= KEY_RESET;  
                when others => next_keyevent_s <= KEY_OTHER;  
            end case;
    end process scancode_proc;
	 -- assign the state-signals to the output bus
	 keydigit <= keydigit_s;
	 keyevent <= keyevent_s;
	 keytrigger <= keytrigger_s;
end architecture behav;