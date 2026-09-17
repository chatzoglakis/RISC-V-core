library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection_unit_tb is
end hazard_detection_unit_tb;

architecture Behavioral of hazard_detection_unit_tb is

    constant S_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "01000";
    constant B_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "11000";
    constant R_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "01100";
    constant I_ALU_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "00100"; -- ADDI, SLTI, etc.
    constant LOAD: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant LUI: STD_LOGIC_VECTOR(4 downto 0) := "01101";
    constant AUIPC: STD_LOGIC_VECTOR(4 downto 0) := "00101";

    signal IF_ID_opcode: STD_LOGIC_VECTOR(4 downto 0);
    signal ID_EX_opcode: STD_LOGIC_VECTOR(4 downto 0);
    signal ID_EX_rd: STD_LOGIC_VECTOR(4 downto 0);
    signal IF_ID_rs1: STD_LOGIC_VECTOR(4 downto 0);
    signal IF_ID_rs2: STD_LOGIC_VECTOR(4 downto 0);
    signal stall_pipeline: STD_LOGIC;

begin

    dut: entity work.hazard_detection_unit
     port map(
        IF_ID_opcode => IF_ID_opcode,
        ID_EX_opcode => ID_EX_opcode,
        ID_EX_rd => ID_EX_rd,
        IF_ID_rs1 => IF_ID_rs1,
        IF_ID_rs2 => IF_ID_rs2,
        stall_pipeline => stall_pipeline
    );

    stimuli: process
    begin
        report "testing rs1 check";
        IF_ID_opcode <= R_TYPE;
        ID_EX_opcode <= LOAD;
        IF_ID_rs1 <= "00010";
        IF_ID_rs2 <= "11111";
        ID_EX_rd <= "00010";
        wait for 10 ns;
        assert stall_pipeline = '1' report "FAILED LOAD-USE HAZARD DETECTION WITH R_TYPE (RS1)" severity error;

        IF_ID_opcode <= AUIPC;
        wait for 10 ns;
        assert stall_pipeline = '0' report "WRONG DETECTION: AUIPC INSTRUCTIONS DONT HAVE AN RS1 FIELD" severity error;

        report "testing rs2 check";
        IF_ID_opcode <= S_TYPE;
        ID_EX_rd <= "11111";
        wait for 10 ns;
        assert stall_pipeline = '1' report "FAILED LOAD-USE HAZARD DETECTION WITH S_TYPE (RS2)" severity error;

        IF_ID_opcode <= LOAD;
        wait for 10 ns;
        assert stall_pipeline = '0' report "WRONG DETECTION: LOAD INSTRUCTIONS DONT HAVE AN RS2 FIELD" severity error;

        report "testing rd = 0";
        IF_ID_opcode <= R_TYPE;
        ID_EX_rd <= "00000";
        wait for 10 ns;
        assert stall_pipeline = '0' report "STALLING SHOULDN'T OCCUR WHEN RD = 0" severity error;

        std.env.finish;
        
    end process;


end Behavioral;
