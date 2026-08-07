library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ram is
    generic (
        ADDRESS_WIDTH: integer := 12
    );

    port(
        clk: in STD_LOGIC;
        we: in STD_LOGIC_VECTOR(3 downto 0); --each bit corresponds to one word byte
        address: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        data_in: in STD_LOGIC_VECTOR(31 downto 0);
        data_out: out STD_LOGIC_VECTOR(31 downto 0)
    );
end ram;

architecture rtl of ram is

    type ram_type is array(0 to (2**ADDRESS_WIDTH)-1) of STD_LOGIC_VECTOR(31 downto 0);
    -- Initialize the RAM with compiled machine code for testing purposes
    signal ram: ram_type := (
        0 => x"00000093", -- PC = 0:  addi x1, x0, 0
        1 => x"00500113", -- PC = 4:  addi x2, x0, 5
        2 => x"00108093", -- PC = 8:  addi x1, x1, 1  <-- LOOP START
        3 => x"02102023", -- PC = 12: sw   x1, 32(x0)
        4 => x"fe209ce3", -- PC = 16: bne  x1, x2, -8
        5 => x"0000006f", -- PC = 20: jal  x0, 0      <-- END PROGRAM
        
        -- The rest of the 16KB memory is filled with zeros
        others => x"00000000"
    );

begin

    process(clk)
    begin
        data_out <= ram(to_integer(unsigned(address))); 
        if rising_edge(clk) then

            if we(0) = '1' then
                ram(to_integer(unsigned(address)))(7 downto 0) <= data_in(7 downto 0);
            end if;

            if we(1) = '1' then
                ram(to_integer(unsigned(address)))(15 downto 8) <= data_in(15 downto 8);
            end if;

            if we(2) = '1' then
                ram(to_integer(unsigned(address)))(23 downto 16) <= data_in(23 downto 16);
            end if;

            if we(3) = '1' then
                ram(to_integer(unsigned(address)))(31 downto 24) <= data_in(31 downto 24);
            end if;
        end if;
    end process;

end rtl;
