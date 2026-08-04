library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_file_tb is
end reg_file_tb;

architecture Behavioral of reg_file_tb is
    constant ADDRESS_WIDTH: integer := 5;
    constant DATA_WIDTH: integer := 32;
    constant CLK_PERIOD: time := 10 ns;

    signal clk: STD_LOGIC;
    signal rs1: STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
    signal rs2: STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
    signal rd: STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 downto 0);
    signal we: STD_LOGIC;
    signal data_in: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal reg_out1: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal reg_out2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

begin

    dut: entity work.reg_file
        port map (
            clk => clk,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            we => we,
            data_in => data_in,
            reg_out1 => reg_out1,
            reg_out2 => reg_out2
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
        report "Testing read/write";
        we <= '1';
        data_in <= x"FFFFFFFF";
        rd <= "00001";
        rs1 <= "00001";
        rs2 <= "00001";
        wait for 100 ns;
        assert reg_out1 = x"FFFFFFFF" and reg_out2 = x"FFFFFFFF" report "Error in reading/writing" severity error;

        report "Testing write enable";
        we <= '0';
        data_in <= x"21F7B1A0";
        rd <= "00001";
        rs1 <= "00001";
        rs2 <= "00001";
        wait for 100 ns;
        assert reg_out1 = x"FFFFFFFF" and reg_out2 = x"FFFFFFFF" report "Error in write enable" severity error;

        report "Testing register x0";
        we <='1';
        data_in <= x"0F320910";
        rd <= "00000";
        rs1 <= "00000";
        wait for 100 ns;
        assert reg_out1 = x"00000000" report "ERROR IN REGISTER x0" severity error;

        report "Simulation complete" severity failure;

    end process;

end Behavioral;
