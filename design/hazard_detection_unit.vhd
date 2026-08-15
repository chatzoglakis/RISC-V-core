library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection_unit is
    port(
        new_opcode: in STD_LOGIC_VECTOR(4 downto 0);
        IF_ID_opcode: in STD_LOGIC_VECTOR(4 downto 0);
        IF_ID_rd: in STD_LOGIC_VECTOR(4 downto 0);
        new_rs1: in STD_LOGIC_VECTOR(4 downto 0);
        new_rs2: in STD_LOGIC_VECTOR(4 downto 0);

        stall_pipeline: out STD_LOGIC
    );
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is

begin

    process(all)
    begin
        if IF_ID_opcode = "00000" and (IF_ID_rd = new_rs1 or ( IF_ID_rd = new_rs2 and (new_opcode = "01100" or new_opcode = "11000" or new_opcode = "01000"))) and IF_ID_rd /= "00000" then
            stall_pipeline <= '1';
        else
            stall_pipeline <= '0';
        end if;
    end process;

end rtl;
