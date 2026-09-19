library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_loader is
    port (
        clk: in STD_LOGIC;
        prog_mode: in STD_LOGIC;
        rx: in STD_LOGIC;
        instruction: out STD_LOGIC_VECTOR(31 downto 0);
        address: out STD_LOGIC_VECTOR(11 downto 0);
        we: out STD_LOGIC_VECTOR(3 downto 0)
    );
end program_loader;

architecture rtl of program_loader is

    signal done: STD_LOGIC;
    signal address_num: integer := 0;

begin

    uart_receiver: entity work.uart_receiver
     port map(
        clk => clk,
        rx => rx,
        done => done,
        data => instruction
    );

    process (all)
    begin
        if rising_edge(clk) then
            if prog_mode = '0' then
                we <= "0000";
                address_num <= 0;
            else
                we <= "0000";
                if done = '1' then
                    we <= "1111";
                    address_num <= address_num + 1;
                end if;
            end if;
        end if;
    end process;
    address <= STD_LOGIC_VECTOR(to_unsigned(address_num, 12));

end rtl;
