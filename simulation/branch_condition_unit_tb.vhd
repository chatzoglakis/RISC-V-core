library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branch_condition_unit_tb is
end branch_condition_unit_tb;

architecture Behavioral of branch_condition_unit_tb is

    signal funct3: STD_LOGIC_VECTOR(2 downto 0);
    signal ALUout: STD_LOGIC_VECTOR(31 downto 0);
    signal en: STD_LOGIC;
    signal take_branch: STD_LOGIC;

begin

    dut: entity work.branch_condition_unit
     port map(
        funct3 => funct3,
        ALUout => ALUout,
        en => en,
        take_branch => take_branch
    );

    stimuli: process 
    begin
        en <= '1';

        report "testing BEQ";
        funct3 <= "000";
        ALUout <= x"00000000";
        wait for 50 ns;
        assert take_branch = '1' report "BEQ FAILED" severity error;
        ALUout <= x"00A00012";
        wait for 50 ns;
        assert take_branch = '0' report "BEQ FAILED" severity error;

        report "testing BNE";
        funct3 <= "001";
        ALUout <= x"00000000";
        wait for 50 ns;
        assert take_branch = '0' report "BNE FAILED" severity error;
        ALUout <= x"00A00012";
        wait for 50 ns;
        assert take_branch = '1' report "BNE FAILED" severity error;
 
        report "testing BGE";
        funct3 <= "101";
        ALUout <= x"00000001";
        wait for 50 ns;
        assert take_branch = '0' report "BGE FAILED" severity error;
        ALUout <= x"00000000";
        wait for 50 ns;
        assert take_branch = '1' report "BGE FAILED" severity error;

        report "testing BLT";
        funct3 <= "100";
        ALUout <= x"00000001";
        wait for 50 ns;
        assert take_branch = '1' report "BLT FAILED" severity error;
        ALUout <= x"00000000";
        wait for 50 ns;
        assert take_branch = '0' report "BLT FAILED" severity error;

        std.env.finish;
    end process;

end Behavioral;
