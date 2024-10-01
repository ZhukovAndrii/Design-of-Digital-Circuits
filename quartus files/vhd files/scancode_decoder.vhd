library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use WORK.globals.all;

entity scancode_decoder is
	port(
		signal clock: in std_logic;
		signal char_code: in std_logic_vector(7 downto 0);
		signal char_ready: in std_logic;
		signal reset: in std_logic;
		signal keydigit: out std_logic_vector(3 downto 0);
		signal keyevent: out key_event_type;
		signal keytrigger: out std_logic  --- 1 is only when the num or event is transmitted
	);
end scancode_decoder;

architecture behav of scancode_decoder is
	-- these signal are all made for a proper work of a state machine
	type state_type is (idle, new_code, break, hold);
   signal state, next_state: state_type := hold;
   signal keyevent_s, next_keyevent_s: key_event_type := KEY_OTHER;
   signal next_keydigit: std_logic_vector(3 downto 0) := "0000";
   signal keytrigger_s, next_keytrigger_s: std_logic := '0';
	begin
		storage_process: process(clock, reset) -- the storage process
		begin
			if reset = '1' then -- initializing
				state <= hold;
				keydigit <= (others => '0');
				keyevent <= KEY_OTHER;
				keytrigger_s <= '0';
			elsif rising_edge(clock) then --change the state on the rising edge of the system clock
				state <= next_state;
				keyevent <= next_keyevent_s;
				keydigit <= next_keydigit;
				keytrigger_s <= next_keytrigger_s;	
        end if;
		  
		end process storage_process;

		next_state_process : process (char_ready, char_code, state) -- computes the next_state and next_keytrigger_s
      begin
			next_state <= state;
			next_keytrigger_s <= keytrigger_s;
		  
			case state is
            when hold => 
					if char_ready = '1' then
						if char_code = x"E0" then
							next_state <= hold;
							next_keytrigger_s <= '0';
						elsif char_code = x"F0" then
							next_state <= break;
							next_keytrigger_s <= '0';
						else
							next_state <= new_code;
							next_keytrigger_s <= '1';
						end if;
					end if;
				when new_code =>
					next_keytrigger_s <= '0';
					if char_ready = '0' then
						next_state <= hold;
					end if;	
            when break =>   -- we are supposed to skip this "break" char and the next one
					if  char_ready = '1' then 
						if char_code = x"F0" then
							next_state <= break;
						else
							next_state <= idle;
							next_keytrigger_s <= '0';
						end if;	
					end if;
            when idle => 
					if char_ready = '0' then
						next_state <= hold;
						next_keytrigger_s <= '0';
					end if;
				end case;
		end process next_state_process;

		scancode_process : process(char_code) is
		begin
			next_keydigit <= "1111";
			next_keyevent_s <= KEY_OTHER;
         case char_code is
					 when x"4A" => next_keyevent_s <= KEY_DIV;
					 when x"7C" => next_keyevent_s <= KEY_MUL;
					 when x"7B" => next_keyevent_s <= KEY_SUB;
                when x"79" => next_keyevent_s <= KEY_ADD;
                when x"5A" => next_keyevent_s <= KEY_ENTER;
                when x"76" => next_keyevent_s <= KEY_RESET;  
                when x"70" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0000";
                when x"69" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0001";
                when x"72" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0010";
                when x"7A" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0011";
                when x"6B" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0100";
                when x"73" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0101";
                when x"74" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0110";
                when x"6C" => next_keyevent_s <= KEY_NUM; next_keydigit <= "0111";
                when x"75" => next_keyevent_s <= KEY_NUM; next_keydigit <= "1000";
                when x"7D" => next_keyevent_s <= KEY_NUM; next_keydigit <= "1001";
                when others => next_keyevent_s <= KEY_OTHER;  
			end case;
 
		end process scancode_process;
		
		keytrigger <= keytrigger_s;
		
end architecture;