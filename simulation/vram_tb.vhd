library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vram_tb is
end vram_tb;

architecture Behavioral of vram_tb is

    constant CLK_A_PERIOD: time := 30 ns;
    constant CLK_B_PERIOD: time := 10 ns;

    signal clk_a: STD_LOGIC;
    signal we_a: STD_LOGIC;
    signal address_a: STD_LOGIC_VECTOR(17 downto 0);
    signal data_a: STD_LOGIC_VECTOR(7 downto 0);

    signal clk_b: STD_LOGIC;
    signal address_b: STD_LOGIC_VECTOR(17 downto 0);
    signal data_b: STD_LOGIC_VECTOR(7 downto 0);

begin

    dut: entity work.vram
     port map(
        clk_a => clk_a,
        we_a => we_a,
        address_a => address_a,
        data_a => data_a,
        clk_b => clk_b,
        address_b => address_b,
        data_b => data_b
    );

    clk_a_proc: process
    begin
        clk_a <= '0';
        wait for CLK_A_PERIOD;
        clk_a <= '1';
        wait for CLK_A_PERIOD;
    end process;

    clk_b_proc: process
    begin
        clk_b <= '0';
        wait for CLK_B_PERIOD;
        clk_b <= '1';
        wait for CLK_B_PERIOD;
    end process;

    stimuli: process
    begin
        report "testing write enable";
        we_a <= '0';
        address_a <= "000000000000000000";
        address_b <= "000000000000000000";
        data_a <= x"01";
        wait for 100 ns;
        assert data_b /= x"01" report "WE ENABLE FAILED: VRAM SHOULD NOT BE WRITTEN ON WHEN we_a IS 0" severity error;
        we_a <= '1';
        wait for 100 ns;
        assert data_b = x"01" report "WE ENABLE FAILED: VRAM SHOULD BE WRITTEN ON WHEN we_a IS 1" severity error;

        std.env.finish;
    end process;

end Behavioral;
