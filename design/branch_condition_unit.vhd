library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branch_condition_unit is
    port(
        funct3: in STD_LOGIC_VECTOR(2 downto 0);
        ALUout: in STD_LOGIC_VECTOR(31 downto 0);
        en: in STD_LOGIC;
        take_branch: out STD_LOGIC
    );
end branch_condition_unit;

architecture rtl of branch_condition_unit is

begin

    process(all)
    begin
        take_branch <='0';

        if en = '1' then
            -- ">=" and "<" comparisons use slt and sltu operations to determine if branch should be taken, BNE and BEQ use subtraction
            -- That means that when slt/ sltu returns 1 => rs1 < rs2, and when it returns 0 => rs1 >= rs2
            -- when subtraction returns 0 => rs1 = rs2, when it returns non-zero number => rs1 /= rs2
            --Therefore for greater or equal branches (BGE, BGEU) and for branch equal (BEQ) the branch is taken when the ALU output is zero
            -- For branch not equal (BNE) and for less-than branches (BLT, BLTU), the branch is taken when the ALU output is non zero
            case funct3 is
            when "000" | "101" | "111" => --BEQ, BGE, BGEU
                if ALUout = x"00000000" then
                    take_branch <= '1';
                end if;

            when "001" |"100" | "110" => --BNE,BLT, BLTU
                if ALUout /= x"00000000" then
                    take_branch <= '1';
                end if;
                
            when others => take_branch <= '0';

            end case;
        end if;
    end process;
end rtl;
