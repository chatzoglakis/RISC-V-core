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
    signal byte: STD_LOGIC_VECTOR(7 downto 0);
    signal assemble_reg: STD_LOGIC_VECTOR(31 downto 0);
    signal done_delayed: STD_LOGIC := '0';
    signal byte_count: integer range 0 to 3 := 0;

begin

    uart_receiver: entity work.uart_receiver
     port map(
        clk => clk,
        rx => rx,
        done => done,
        data => byte
    );

    process (all)
    begin
        if rising_edge(clk) then
            if prog_mode = '0' then
                we <= "0000";
                address_num <= 0;
                byte_count <= 0;
                done_delayed <= '0';
            else
                done_delayed <= done;
                we <= "0000";

                if we = "1111" then
                    address_num <= address_num + 1;
                end if;

                if done = '1' and done_delayed = '0' then
                    assemble_reg <= byte & assemble_reg(31 downto 8);

                    if byte_count = 3 then
                        byte_count <= 0;
                        we <= "1111";
                    else
                        byte_count <= byte_count + 1;
                    end if;
                end if;    
            end if;
        end if;
    end process;
    instruction <= assemble_reg;
    address <= STD_LOGIC_VECTOR(to_unsigned(address_num, 12));

end rtl;
