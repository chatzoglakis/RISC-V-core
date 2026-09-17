library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection_unit is
    port(
        IF_ID_opcode: in STD_LOGIC_VECTOR(4 downto 0);
        ID_EX_opcode: in STD_LOGIC_VECTOR(4 downto 0);
        ID_EX_rd: in STD_LOGIC_VECTOR(4 downto 0);
        IF_ID_rs1: in STD_LOGIC_VECTOR(4 downto 0);
        IF_ID_rs2: in STD_LOGIC_VECTOR(4 downto 0);

        stall_pipeline: out STD_LOGIC
    );
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is

    constant S_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "01000";
    constant B_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "11000";
    constant R_TYPE: STD_LOGIC_VECTOR(4 downto 0) := "01100";
    constant JAL: STD_LOGIC_VECTOR(4 downto 0) := "11011";
    constant LOAD: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant AUIPC: STD_LOGIC_VECTOR(4 downto 0) := "00101";
    constant LUI: STD_LOGIC_VECTOR(4 downto 0) := "01101";

    --checks if IF_ID instruction has a valid rs1 field
    pure function has_rs1(IF_ID_opcode: STD_LOGIC_VECTOR(4 downto 0)) return boolean is
    begin
        return (IF_ID_opcode /= AUIPC and IF_ID_opcode /= JAL and IF_ID_opcode /= LUI);
    end function;

    --checks if IF_ID instruction has a valid rs2 field
    pure function has_rs2(IF_ID_opcode: STD_LOGIC_VECTOR(4 downto 0)) return boolean is
    begin
        return (IF_ID_opcode = R_TYPE or IF_ID_opcode = B_TYPE or IF_ID_opcode = S_TYPE);
    end function;
    
begin

    process(all)
    begin
        if (ID_EX_opcode = LOAD) and 
           ((ID_EX_rd = IF_ID_rs1 and has_rs1(IF_ID_opcode)) or 
           ( ID_EX_rd = IF_ID_rs2 and has_rs2(IF_ID_opcode))) and 
           ID_EX_rd /= "00000" then

            stall_pipeline <= '1';
        else
            stall_pipeline <= '0';
        end if;
    end process;

end rtl;
