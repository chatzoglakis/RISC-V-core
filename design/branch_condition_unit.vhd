library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branch_condition_unit is
    port(
        funct: in STD_LOGIC_VECTOR(2 downto 0);
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

        if en = '0' then
            case funct is
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
