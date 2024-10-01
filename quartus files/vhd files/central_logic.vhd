library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use WORK.globals.all;

entity central_logic is
	port(
		signal clock : in std_logic;
		signal reset : in std_logic;
      signal keytrigger : in std_logic;
      signal keyevent : in key_event_type;
      signal keydigit : in std_logic_vector(3 downto 0);
      signal operator : out operator_type;
      signal operand1 : out std_logic_vector(7 downto 0);
      signal operand2 : out std_logic_vector(7 downto 0);
      signal result : out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of central_logic is
	type state_type is (INPUT_OP1, INPUT_OP2, FINISHED, DO_RESET);
   signal state, next_state: state_type; -- for state machine
   signal next_operator: operator_type;
   signal demux1, demux2: std_logic := '0'; -- trigger for operand's register
	signal next_result : std_logic_vector(15 downto 0);
   signal operand1_s, operand2_s : std_logic_vector(7 downto 0) := (others => '0');
   signal reset_s: std_logic; -- the reset for the registers
begin
   
    storage_process: process(clock, reset )
    begin
         if reset = '1' or state = DO_RESET then --reset
            state <= INPUT_OP1;
            operator <= UNDEF;
         elsif rising_edge(clock) then -- assign next_state 
            state <= next_state;
            operator <= next_operator;
         end if;
    end process;
	 
    next_state_process: process(state, keytrigger) -- compute next_state
	 begin
		next_state <= state; --initialization
      case state is
        when INPUT_OP1 => -- waiting for an operator
          if keytrigger = '1' then
            case keyevent is
              when KEY_ADD =>
                next_operator <= ADD;
                next_state <= INPUT_OP2;
              when KEY_SUB =>
                next_operator <= SUB;
                next_state <= INPUT_OP2;
              when KEY_MUL =>
                next_operator <= MUL;
                next_state <= INPUT_OP2;
              when KEY_DIV =>
                next_operator <= DIV;
                next_state <= INPUT_OP2;
              when KEY_NUM =>
                 next_operator <= UNDEF;
              when KEY_RESET => -- reset
                next_state <= DO_RESET;
              when others =>
					 null;
            end case;
          end if;
        when INPUT_OP2 => -- waiting for KEY_ENTER
          if keytrigger = '1' then
             case keyevent is
               when KEY_NUM =>
                  null;
               when KEY_ENTER =>
                  next_state <= FINISHED;
               when KEY_RESET => -- reset
                  next_state <= DO_RESET;
               when others =>
						null;
              end case;
			 end if;
        when FINISHED => -- waiting for KEY_RESET
          if (keytrigger = '1') and (keyevent = KEY_RESET) then
				next_state <= DO_RESET;
          end if;
        when DO_RESET => -- initialize state and operator
          next_state <= INPUT_OP1;
			 next_operator <= UNDEF;
        end case;
    end process next_state_process; 
    
    demux: process(clock, reset) -- result bus assignment + triggers for registers calculation
    begin
        if (reset = '1' or state = DO_RESET) then --reset
            operand1 <= "00000000";
            operand2 <= "00000000";
            result <= "0000000000000000";
            demux2 <= '0';
            demux1 <= '0';
        else -- output
            result <= next_result;
            operand1 <= operand1_s;
            operand2 <= operand2_s;
        end if;
        
        if keyevent = KEY_NUM then
				case state is 
					when INPUT_OP1 => -- enable the 1st register
						demux1 <= keytrigger;
                  demux2 <= '0';
               when INPUT_OP2 => -- enable the 2nd register
                  demux1 <= '0';
                  demux2 <= keytrigger;
               when others => -- none
                  demux1 <= '0';
						demux2 <= '0';
            end case;
        else
            demux1 <= '0';
            demux2 <= '0';
        end if;
    end process demux;
    
    arithmetic_unit: process(clock, reset) -- compute the next_result
    begin
      next_result <= "0000000000000000"; --initialize the next_result
      if keyevent = KEY_ENTER then
          case next_operator is
             when ADD => next_result <= conv_std_logic_vector( conv_integer(unsigned(operand1_s))
                          + conv_integer(unsigned(operand2_s)), 16);
             when SUB => next_result <= conv_std_logic_vector( conv_integer(unsigned(operand1_s))
                          - conv_integer(unsigned(operand2_s)), 16);
             when MUL => next_result <= conv_std_logic_vector( conv_integer(unsigned(operand1_s))
                          * conv_integer(unsigned(operand2_s)), 16);
             when DIV => next_result <= conv_std_logic_vector( conv_integer(unsigned(operand1_s))
                          / conv_integer(unsigned(operand2_s)), 16);
             when others  => next_result <= "0000000000000000"; -- none
           end case;
      end if;
	 end process;
    
    reset_s <= '1' when (reset = '1' OR (state = DO_RESET)) else '0'; -- reset for registers
    
    operand_1: entity work.dec_shift_reg(behav)
      generic map(WIDTH => 8)
      port map (
      clock => clock,
      reset => reset_s,
      digit => keydigit,
      trigger => demux1,
      max => "01100011",
      Q => operand1_s);
    
    operand_2: entity work.dec_shift_reg(behav)
      generic map(WIDTH => 8)
      port map (
      clock => clock,
      reset => reset_s,
      digit => keydigit,
      trigger => demux2,
      max => "01100011",
      Q => operand2_s);
      
end architecture;