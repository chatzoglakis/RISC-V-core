library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwarding_unit_tb is
end forwarding_unit_tb;

architecture Behavioral of forwarding_unit_tb is

    signal EX_MEM_reg_we: STD_LOGIC;
    signal MEM_WB_reg_we: STD_LOGIC;
    signal ID_EX_rs1: STD_LOGIC_VECTOR(4 downto 0);
    signal ID_EX_rs2: STD_LOGIC_VECTOR(4 downto 0);
    signal EX_MEM_rd: STD_LOGIC_VECTOR(4 downto 0);
    signal MEM_WB_rd: STD_LOGIC_VECTOR(4 downto 0);
    signal ex_stage_opcode: STD_LOGIC_VECTOR(4 downto 0);
    signal forward_A: STD_LOGIC_VECTOR(1 downto 0);
    signal forward_B: STD_LOGIC_VECTOR(1 downto 0);

begin

    dut: entity work.forwarding_unit
        port map(
            EX_MEM_reg_we => EX_MEM_reg_we,
            MEM_WB_reg_we => MEM_WB_reg_we,
            ID_EX_rs1 => ID_EX_rs1,
            ID_EX_rs2 => ID_EX_rs2,
            EX_MEM_rd => EX_MEM_rd,
            MEM_WB_rd => MEM_WB_rd,
            ex_stage_opcode => ex_stage_opcode,
            forward_A => forward_A,
            forward_B => forward_B
        );

    stimuli: process
    begin
        report "Testing with both WE's enabled and all registers matching";
        EX_MEM_reg_we <= '1';
        MEM_WB_reg_we <= '1';
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00001";
        EX_MEM_rd <= "00001";
        MEM_WB_rd <= "00001";
        ex_stage_opcode <= "01100";
        wait for 50 ns;
        assert forward_A = "01" report "ERROR WHEN BOTH WE's ENABLED AND ALL REGISTERS MATCHING" severity error;
        assert forward_B = "01" report "ERROR WHEN BOTH WE's ENABLED AND ALL REGISTERS MATCHING" severity error;

        report "Testing with both WE's enabled and one register matching";
        ID_EX_rs2 <= "00010";
        wait for 50 ns;
        assert forward_A = "01" report "ERROR WHEN BOTH WE's ENABLED AND ONE REGISTER MATCHING" severity error;
        assert forward_B = "00" report "ERROR WHEN BOTH WE's ENABLED AND ONE REGISTER MATCHING" severity error;
        ID_EX_rs2 <= "00001";

        report "Testing with only MEM_WB_reg_we enabled";
        EX_MEM_reg_we <= '0';
        MEM_WB_reg_we <= '1';
        wait for 50 ns;
        assert forward_A = "10" report "ERROR WHEN ONLY MEM_WB_reg_we ENABLED" severity error;
        assert forward_B = "10" report "ERROR WHEN ONLY MEM_WB_reg_we ENABLED" severity error;

        report "Testing opcode check";
        ex_stage_opcode <= "00100";
        wait for 50 ns;
        assert forward_B = "00" report "ERROR IN OPCODE CHECK" severity error;
        ex_stage_opcode <= "01100";

        report "Testing x0 check";
        EX_MEM_rd <= "00000";
        MEM_WB_rd <= "00000";
        ID_EX_rs1 <= "00000";
        wait for 50 ns;
        assert forward_A = "00" report "ERROR IN x0 CHECK" severity error;
        assert forward_B = "00" report "ERROR IN x0 CHECK" severity error;

        std.env.finish;

    end process;
end Behavioral;
