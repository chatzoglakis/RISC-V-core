library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity reg_file is
    generic (
        ADDRESS_WIDTH: integer := 5;
        DATA_WIDTH: integer := 32     
    );

    port (
        clk: in STD_LOGIC;
        rs1: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        rs2: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        rd: in STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
        we: in STD_LOGIC;
        data_in: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        reg_out1: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        reg_out2: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end reg_file;

architecture rtl of reg_file is

    type reg_array_type is array (0 to (2**ADDRESS_WIDTH) - 1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal reg_file: reg_array_type;

begin

    reg_out1 <= (others => '0') when unsigned(rs1) = 0
            else reg_file(to_integer(unsigned(rs1)));

    reg_out2 <= (others => '0') when unsigned(rs2) = 0
            else reg_file(to_integer(unsigned(rs2)));

    process(clk)
    begin

        if rising_edge(clk) then
            if we = '1' and unsigned(rd) /= 0 then
                reg_file(to_integer(unsigned(rd))) <= data_in;
            end if;
        end if;
    end process;


end rtl;
