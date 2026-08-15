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

begin

    process(all)
        variable forwarded_A_in_EX_MEM: std_logic;
        variable forwarded_B_in_EX_MEM: std_logic;
    begin
        forward_A <= "00";
        forward_B <= "00";

        forwarded_A_in_EX_MEM := '0';
        forwarded_B_in_EX_MEM := '0';

        if EX_MEM_reg_we = '1' and EX_MEM_rd /= "00000" then
            if EX_MEM_rd = ID_EX_rs1 then
                forward_A <= "01";
                forwarded_A_in_EX_MEM := '1';
            end if;

            if (ex_stage_opcode = "01100" or ex_stage_opcode = "11000" or ex_stage_opcode = "01000") and EX_MEM_rd = ID_EX_rs2 then
                forward_B <= "01";
                forwarded_B_in_EX_MEM := '1';
            end if;
        end if;

        if MEM_WB_reg_we = '1' and MEM_WB_rd /= "00000" then
            if MEM_WB_rd = ID_EX_rs1 and forwarded_A_in_EX_MEM = '0' then
                forward_A <= "10";
            end if;

            if (ex_stage_opcode = "01100" or ex_stage_opcode = "11000" or ex_stage_opcode = "01000") and MEM_WB_rd = ID_EX_rs2 and forwarded_B_in_EX_MEM = '0' then
                forward_B <= "10";
            end if;
        end if;
        
    end process;

end rtl;
