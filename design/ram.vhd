library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ram is
    generic (
        ADDRESS_WIDTH: integer := 12
    );

    port(
        clk: in STD_LOGIC;
        en: STD_LOGIC;
        write_en: in STD_LOGIC_VECTOR(3 downto 0); --each bit corresponds to one word byte
        address: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        data_in: in STD_LOGIC_VECTOR(31 downto 0);
        data_out: out STD_LOGIC_VECTOR(31 downto 0)
    );
end ram;

architecture Behavioral of ram is

    type ram_type is array(0 to (2**ADDRESS_WIDTH)-1) of STD_LOGIC_VECTOR(31 downto 0);

    signal ram: ram_type := (others => x"00000000";

begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                data_out <= ram(to_integer(unsigned(address))); 

                if write_en(0) = '1' then
                    ram(to_integer(unsigned(address)))(7 downto 0) <= data_in(7 downto 0);
                end if;

                if write_en(1) = '1' then
                    ram(to_integer(unsigned(address)))(15 downto 8) <= data_in(15 downto 8);
                end if;

                if write_en(2) = '1' then
                    ram(to_integer(unsigned(address)))(23 downto 16) <= data_in(23 downto 16);
                end if;

                if write_en(3) = '1' then
                    ram(to_integer(unsigned(address)))(31 downto 24) <= data_in(31 downto 24);
                end if;
            end if;
    end if;
end process;

end Behavioral;
