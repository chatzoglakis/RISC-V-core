library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity video_subsystem_tb is
end video_subsystem_tb;

architecture Behavioral of video_subsystem_tb is

    constant CLK_90_PERIOD: time := 6 ns;
    constant CLK_25_PERIOD: time := 19 ns;

    signal clk_90: STD_LOGIC;
    signal clk_25: STD_LOGIC;
    signal rst: STD_LOGIC;
    signal vram_we: STD_LOGIC;
    signal write_address: STD_LOGIC_VECTOR(17 downto 0);
    signal vram_data_in: STD_LOGIC_VECTOR(7 downto 0);
    signal swap_trigger: STD_LOGIC;
    signal hsync: STD_LOGIC;
    signal vsync: STD_LOGIC;
    signal vga_status: STD_LOGIC;
    signal r: STD_LOGIC_VECTOR(3 downto 0);
    signal g: STD_LOGIC_VECTOR(3 downto 0);
    signal b: STD_LOGIC_VECTOR(3 downto 0);

begin

    dut: entity work.video_subsystem
     port map(
        clk_90 => clk_90,
        clk_25 => clk_25,
        rst => rst,
        vram_we => vram_we,
        write_address => write_address,
        vram_data_in => vram_data_in,
        swap_trigger => swap_trigger,
        hsync => hsync,
        vsync => vsync,
        vga_status => vga_status,
        r => r,
        g => g,
        b => b
    );

    clk_90_proc: process
    begin
        clk_90 <= '0';
        wait for CLK_90_PERIOD / 2;
        clk_90 <= '1';
        wait for CLK_90_PERIOD /2;
    end process;

    clk_25_proc: process
    begin
        clk_25 <= '0';
        wait for CLK_25_PERIOD / 2;
        clk_25 <= '1';
        wait for CLK_25_PERIOD /2;
    end process;

    stimuli: process
    begin
        write_address <= "010001101111100110";
        vram_data_in <= x"a1";
        vram_we <= '1';
        swap_trigger <= '0';
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        report "Testing vga_status flag";
        wait until rising_edge(clk_90);
        swap_trigger <= '1';
        wait until rising_edge(clk_90);
        swap_trigger <= '0';
        wait until vga_status = '1' for 100 ns;
        assert vga_status = '1' report "ERROR: CPU did not register swap request" severity error;
        wait until vga_status = '0' for 20 ms;
        assert vga_status = '0' report "ERROR: VGA controller never acknowledged swap" severity error;
        
        std.env.finish;
    end process;

end Behavioral;
