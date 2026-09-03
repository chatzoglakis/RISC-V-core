library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 320 x 240 = 76,800 pixels per frame. 
-- Double buffered = 153,600 total pixels (bytes).
-- Requires an 18-bit address to access (2^18 = 262,144 maximum addresses)
-- The VRAM is dual ported due to the different clock rates of the cpu and the VGA controller
-- Port A is for writing from the cpu, port B is for reading, used by the VGA controller

entity vram is
    port(
        clk_a: in STD_LOGIC;
        we_a: in STD_LOGIC;
        address_a: in STD_LOGIC_VECTOR(17 downto 0);
        data_a: in STD_LOGIC_VECTOR(7 downto 0);

        clk_b: in STD_LOGIC;
        address_b: in STD_LOGIC_VECTOR(17 downto 0);
        data_b: out STD_LOGIC_VECTOR(7 downto 0)
    );
end vram;

architecture rtl of vram is

    type vram_type is array(0 to 153599) of STD_LOGIC_VECTOR(7 downto 0);
    signal vram: vram_type := (others => x"00");

begin

    process(clk_a)
    begin
        if rising_edge(clk_a) then
            if we_a = '1' then
                vram(to_integer(unsigned(address_a))) <= data_a;
            end if;
        end if;

        if rising_edge(clk_b) then
            data_b <= vram(to_integer(unsigned(address_b)));
        end if;

    end process;

end rtl;
