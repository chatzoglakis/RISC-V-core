library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is

    signal a: STD_LOGIC_VECTOR(31 downto 0);
    signal b: STD_LOGIC_VECTOR(31 downto 0);
    signal op: STD_LOGIC_VECTOR(2 downto 0);
    signal sub_arShift: STD_LOGIC; 
    signal shamt: STD_LOGIC_VECTOR(4 downto 0);
    signal result: STD_LOGIC_VECTOR(31 downto 0);

begin
    dut: entity work.alu
        port map(
            a => a,
            b => b,
            op => op,
            sub_arShift => sub_arShift,
            shamt => shamt,
            result => result
        );

    stimuli: process
    begin
        a <= x"00000001";
        b <= x"00000002";

        report "testing addition";
        op <= "000";
        sub_arShift <= '0';
        wait for 50 ns;
        assert result = x"00000003" report "ADDITION FAILED" severity error;

        report "testing subtraction";
        sub_arShift <= '1';
        wait for 50 ns;
        assert result = x"FFFFFFFF" report "SUBTRACTION FAILED" severity error;

        report "testing logical shift left";
        op <= "001";
        shamt <= "00010";
        wait for 50 ns;
        assert result = x"00000004" report "LOGICAL LEFT SHIT FAILED" severity error;

        a <= x"F0000000";
        report "testing set less than";
        op <= "010";
        wait for 50 ns;
        assert result = x"00000001" report "SLT FAILED" severity error;

        report "testing set less than unsigned";
        op <= "011";
        wait for 50 ns;
        assert result = x"00000000" report "SLTU FAILED" severity error;

        a <= x"00000001";

        report "testing xor";
        op <= "100";
        wait for 50 ns;
        assert result = x"00000003" report "XOR FAILED" severity error;

        report "testing logical right shift";
        a <= x"00000100";
        op <= "101";
        sub_arShift <= '0';
        wait for 50 ns;
        assert result = x"00000040" report  "LOGICAL RIGHT SHIFT FAILED" severity error;

        report "testing arithmetic right shift";
        a <= x"FFFFFF20";
        sub_arShift <= '1';
        wait for 50 ns;
        assert result = x"FFFFFFC8" report  "ARITHMETIC RIGHT SHIFT FAILED" severity error;

        a <= x"00000011";
        b <= x"FFFF0001";
        report "testing or";
        op <= "110";
        wait for 50 ns;
        assert result = x"FFFF0011" report "OR FAILED" severity error;

        report "testing and";
        op <= "111";
        wait for 50 ns;
        assert result = x"00000001" report "AND FAILED" severity error;

        report "Simulation completed" severity failure;

    end process;

end Behavioral;
