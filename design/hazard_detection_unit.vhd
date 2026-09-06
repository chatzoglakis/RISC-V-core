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
    constant LOAD: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant LUI: STD_LOGIC_VECTOR(4 downto 0) := "01101";

begin

    process(all)
    begin
        if (ID_EX_opcode = LOAD or ID_EX_opcode = LUI) and 
           (ID_EX_rd = IF_ID_rs1 or ( ID_EX_rd = IF_ID_rs2 and (IF_ID_opcode = R_TYPE or IF_ID_opcode = B_TYPE or IF_ID_opcode = S_TYPE))) 
           and ID_EX_rd /= "00000" then

            stall_pipeline <= '1';
        else
            stall_pipeline <= '0';
        end if;
    end process;

end rtl;
