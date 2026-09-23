library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwarding_unit is
    port(
        EX_MEM_reg_we: in STD_LOGIC;
        MEM_WB_reg_we: in STD_LOGIC;
        ID_EX_rs1: in STD_LOGIC_VECTOR(4 downto 0);
        ID_EX_rs2: in STD_LOGIC_VECTOR(4 downto 0);
        EX_MEM_rd: in STD_LOGIC_VECTOR(4 downto 0);
        MEM_WB_rd: in STD_LOGIC_VECTOR(4 downto 0);
        ex_stage_opcode: in STD_LOGIC_VECTOR(4 downto 0);

        forward_A: out STD_LOGIC_VECTOR(1 downto 0);
        forward_B: out STD_LOGIC_VECTOR(1 downto 0)
    );
end forwarding_unit;

architecture rtl of forwarding_unit is

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
        forward_A <= "00";
        forward_B <= "00";

        if has_rs1(ex_stage_opcode) then
            if (EX_MEM_reg_we = '1' and EX_MEM_rd /= "00000" and EX_MEM_rd = ID_EX_rs1) then
                forward_A <= "01";
            elsif (MEM_WB_reg_we = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = ID_EX_rs1) then
                forward_A <= "10";
            end if;
        end if;

        if has_rs2(ex_stage_opcode) then
            if (EX_MEM_reg_we = '1' and EX_MEM_rd /= "00000" and EX_MEM_rd = ID_EX_rs2) then
                forward_B <= "01";
            elsif (MEM_WB_reg_we = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = ID_EX_rs2) then
                forward_B <= "10";
            end if;
        end if;
        
    end process;

end rtl;
