library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imm_gen_unit_tb is
end imm_gen_unit_tb;

architecture Behavioral of imm_gen_unit_tb is

    signal instruction: STD_LOGIC_VECTOR(31 downto 0);
    signal imm_sel: STD_LOGIC_VECTOR(2 downto 0);
    signal immediate: STD_LOGIC_VECTOR(31 downto 0);

begin

    dut: entity work.imm_gen_unit
        port map(
            instruction => instruction,
            imm_sel => imm_sel,
            immediate => immediate
        );

    process
    begin
        report "testing I-Type instruction";
        instruction <= x"FF3" & "00010" & "000" & "00001" & "0010011"; --addi x1, x2, 4083
        imm_sel <= "000";
        wait for 100 ns;
        assert immediate = x"FFFFFFF3" report "ERROR IN I-TYPE INSTRUCTION" severity error;

        report "testing S-Type instruction";
        instruction <= "0000101" & "00011" & "00100" & "010" & "00111" & "0100011"; --sw x3, 167(x4)
        imm_sel <= "001";
        wait for 100 ns;
        assert immediate = x"000000A7" report "ERROR IN S-TYPE INSTRUCTION" severity error;

        report "testing B-Type instruction";
        instruction <= '0' & "000001" & "00001" & "00010" & "000" & "0010" & '0' & "1100011"; --beq x2, x1, 36
        imm_sel <= "010";
        wait for 100 ns;
        assert immediate = x"00000024" report "ERROR IN B-TYPE INSTRUCTION" severity error;

        report "testing U-Type instruction";
        instruction <= x"00001" & "00010" & "0010111"; --lui, x2, 1
        imm_sel <= "011";
        wait for 100 ns;
        assert immediate = x"00001000" report "ERROR IN U-TYPE ISNTRUCTION" severity error;

        report "testing J-Type instruction";
        instruction <= '0' & "0000100011" & '0' & "10101110" & "00010" & "1101111"; --jal x2, 712774
        imm_sel <= "100";
        wait for 100 ns;
        assert immediate = x"000AE046" report "ERROR IN J-TYPE INSTRUCTION" severity error;

        report "Simulation completed" severity failure;
    end process;

end Behavioral;
