library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    port(
        instruction: in STD_LOGIC_VECTOR(31 downto 0);
        imm_sel: out STD_LOGIC_VECTOR(2 downto 0);
        ALU_src1: out STD_LOGIC;-- determines 1st source of ALU: 0 = rs1, 1 = PC
        ALU_src2: out STD_LOGIC; -- determines 2nd operand and shamt source of ALU: 0 = rs2, 1 = immediate
        branch_add_src: out STD_LOGIC; --determines branch adder's 2nd operand: 0 = rs1, 1 = PC
        branch_en: out STD_LOGIC;
        ALU_op: out STD_LOGIC_VECTOR(2 downto 0);
        sub_arShift: out STD_LOGIC;
        jump: out STD_LOGIC;
        reg_data_src: out STD_LOGIC_VECTOR(1 downto 0); -- determines data input to the reg file: 00 = ALU output, 01 = data memory output, 10 = immediate, 11 = PC
        reg_we: out STD_LOGIC;
        is_store_inst: out STD_LOGIC
    );
end control_unit;

architecture rtl of control_unit is

begin
    process(instruction)
    begin
        imm_sel <= "000";
        ALU_src1 <= '0';
        ALU_src2 <= '0';
        branch_add_src <= '0';
        branch_en <= '0';
        ALU_op <= "000";
        sub_arShift <= '0';
        jump <= '0';
        reg_data_src <= "00";
        reg_we <= '0';
        is_store_inst <= '0';
        
        case instruction(6 downto 2) is
            when "01101" => --LUI
                reg_we <= '1';
                imm_sel <= "011";
                reg_data_src <= "10";
            
            when "00101" => --AUIPC
                imm_sel <= "011";
                reg_we <= '1';
                ALU_src1 <= '1';
                ALU_src2 <= '1';

            when "00100" => --I-Type (arithmetic/logical)
                reg_we <= '1';
                ALU_src2 <= '1';
                ALU_op <= instruction(14 downto 12); --funct3 field determines ALU operation
                
                if instruction(14 downto 12) = "101" then
                    sub_arShift <= '1' when instruction(30) = '1' else '0'; --differentiate between logical and arithmetic shift right
                end if;
            
            when "01100" => --R-Type
                reg_we <= '1';
                ALU_op <= instruction(14 downto 12); --funct3 field determines ALU operation

                if instruction(14 downto 12) = "101" then
                    sub_arShift <= '1' when instruction(30) = '1' else '0'; --differentiate between logical and arithmetic shift right and betweeen add and sub
                end if;

            when "00000" => --I-Type (loads)
                reg_we <= '1';
                ALU_op <= "000";
                ALU_src2 <= '1';
                reg_data_src <= "01";

            when "01000" => --S-Type
                ALU_src2 <= '1';
                imm_sel <= "001";
                is_store_inst <= '1';

            when "11011" => --JAL
                imm_sel <= "100";
                jump <= '1';
                reg_we <= '1';
                reg_data_src <= "11";

            when "11001" => --JALR
                imm_sel <= "000";
                jump <= '1';    
                reg_we <= '1';
                reg_data_src <= "11";
                branch_add_src <= '1';

            when "11000" => --B-Type
                branch_en <= '1';

                case instruction(14 downto 12) is
                    when "000" | "001" => --BEQ, BNE
                        ALU_op <= "000";
                        sub_arShift <= '1';

                    when "100" | "101" => ALU_op <= "010"; --BLT, BGE
                    when "110" | "111" => ALU_op <= "011"; --BLTU, BGEU 
                end case;

            end case;
        end process;

end rtl;
