library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity two_ff_synchronizer is
    port (
        clk, rst: in STD_LOGIC;
        async_data: in STD_LOGIC;
        sync_data: out STD_LOGIC
    );
end two_ff_synchronizer;

architecture rtl of two_ff_synchronizer is

    signal sync_ff_1, sync_ff_2: STD_LOGIC;

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sync_ff_1: signal is "TRUE";
    attribute ASYNC_REG of sync_ff_2: signal is "TRUE";

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync_ff_1 <= '0';
                sync_ff_2 <= '0';
            else
                sync_ff_1 <= async_data;
                sync_ff_2 <= sync_ff_1;
            end if;
        end if;
    end process;

    sync_data <= sync_ff_2;

end rtl;
