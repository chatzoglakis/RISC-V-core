library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_receiver is
    port(
        clk: in STD_LOGIC;
        rx: in STD_LOGIC;
        done: out STD_LOGIC;
        data: out STD_LOGIC_VECTOR(31 downto 0)
    );
end uart_receiver;

architecture rtl of uart_receiver is

    constant BAUD_RATE: integer := 38_400;
    constant CLK_FREQ: integer := 90_000_000;
    constant MAX: integer := CLK_FREQ /BAUD_RATE --use 2 for simulation;

    type state_type is (IDLE, RECEIVE_START_BIT, RECEIVE_DATA, RECEIVE_STOP_BIT);

    signal state: state_type := IDLE;
    signal baud_count: integer range 0 to MAX - 1 := 0;
    signal shift_reg: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal curr_bit: integer range 0 to 31 := 0;

    

begin

    process (all)
    begin
        if rising_edge(clk) then
            done <= '0';

            case state is
                when IDLE =>
                    curr_bit <= 0;
                    baud_count <= 0;

                    if rx = '0' then
                        state <= RECEIVE_START_BIT;
                    end if;
                
                when RECEIVE_START_BIT =>
                    if baud_count = (MAX / 2) - 1 then
                        baud_count <= 0;
                        state <= RECEIVE_DATA;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when RECEIVE_DATA =>
                    if baud_count = MAX - 1 then
                        shift_reg <= rx & shift_reg(31 downto 1);
                        baud_count <= 0;
                        
                        if curr_bit = 31 then
                            state <= RECEIVE_STOP_BIT;
                        else
                            curr_bit <= curr_bit + 1;
                        end if;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when RECEIVE_STOP_BIT =>
                    if baud_count = MAX - 1 then
                        done <= '1';
                        state <= IDLE;
                        data <= shift_reg;
                    else
                        baud_count <= baud_count + 1;
                    end if;

                when others => state <= IDLE;
            end case;
        end if;
                
    end process;


end rtl;
