library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ram is
    generic (
        DATA_WIDTH: integer := 8;
        ADDRESS_WIDTH: integer := 14 --16KB
    );

    port(
        clk: in STD_LOGIC;
        we: in STD_LOGIC;
        address: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        data_in: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        --4 byte/word burst as output
        data_out: out STD_LOGIC_VECTOR((DATA_WIDTH*4)-1 downto 0)
    );
end ram;

architecture Behavioral of ram is

    type ram_type is array(0 to (2**ADDRESS_WIDTH)-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal ram: ram_type;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            data_out <= ram(to_integer(unsigned(address)));

            if we = '1' then
                ram(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;

end Behavioral;
