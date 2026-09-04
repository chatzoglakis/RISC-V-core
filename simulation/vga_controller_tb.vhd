library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller_tb is
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is

    constant CLK_PERIOD: time := 10 ns;
    -- Number of clock cycles to wait for each event
    constant HSYNC_FALL_CYCLES : integer := 665;
    constant HSYNC_RISE_CYCLES : integer := 96;
    constant VSYNC_FALL_CYCLES : integer := 391240;

    signal clk, rst: STD_LOGIC;
    signal pixel_data: STD_LOGIC_VECTOR(7 downto 0);
    signal hsync: STD_LOGIC;
    signal vsync: STD_LOGIC;
    signal read_address: STD_LOGIC_VECTOR(17 downto 0);
    signal r,g,b: STD_LOGIC_VECTOR(3 downto 0);

begin
    vga_controller: entity work.vga_controller
     port map(
        clk => clk,
        rst => rst,
        pixel_data => pixel_data,
        hsync => hsync,
        vsync => vsync,
        read_address => read_address,
        r => r,
        g => g,
        b => b
    );

    clk_proc: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimuli: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        pixel_data <= "01110000";

        -- Offset the testbench by half a clock cycle
        wait for CLK_PERIOD / 2;

        report "testing vsync and hsync output";
        assert hsync = '1' report "1.HSYNC ERROR: SHOULD BE 1" severity error;
        assert vsync = '1' report "1.VSYNC ERROR: SHOULD BE 1" severity error;

        wait for HSYNC_FALL_CYCLES * CLK_PERIOD;
        assert hsync = '0' report "2.HSYNC ERROR: SHOULD BE 0" severity error;

        wait for HSYNC_RISE_CYCLES * CLK_PERIOD;
        assert hsync = '1' report "3.HSYNC ERROR: SHOULD BE 1" severity error;

        wait for VSYNC_FALL_CYCLES * CLK_PERIOD;
        assert vsync = '0' report "4. VSYNC ERROR: SHOULD BE 0" severity error;
        
        report "testing reset signal";
        rst <= '1';
        wait for 10 ns;
        assert vsync = '1' and hsync = '1' report "RESET SYNC ERROR" severity error;
        assert r = "0000" and g = "0000" and b = "0000" report "RESET RGB ERROR" severity error;
        rst <= '0';

        report "testing rgb";
        pixel_data <= "11010001";
        wait for 10 ns;
        assert r = "1101" report "ERROR IN RED COLOR" severity error;
        assert g = "1001" report "ERROR IN GREEN COLOR" severity error;
        assert b = "0101" report "ERROR IN BLUE COLOR" severity error;

        report "testing read address";
        wait for 240 ns;
        assert read_address = "000000000011111010";

        std.env.finish;

    end process;

end Behavioral;
