library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port(
        a: in STD_LOGIC_VECTOR(31 downto 0);
        b: in STD_LOGIC_VECTOR(31 downto 0);
        op: in STD_LOGIC_VECTOR(2 downto 0);
        sub_arShift: in STD_LOGIC; --when 1: 000 = sub and 101 = sra, when 0: 000 = add and 101 = srl
        shamt: in STD_LOGIC_VECTOR(4 downto 0);
        signed_comp: in STD_LOGIC;
        result: out STD_LOGIC_VECTOR(31 downto 0);
        less_than_flag: out STD_LOGIC --used in subtraction to determine if a < b or b >= a (helpful for branch instructions)
    );
end alu;

architecture rtl of alu is

    --Signals used to calculate the value of the less_than_flag
    signal a_ext: STD_LOGIC_VECTOR(32 downto 0);
    signal b_ext: STD_LOGIC_VECTOR(32 downto 0);
    signal intermediate_result: STD_LOGIC_VECTOR(32 downto 0);

begin
    process(all)
    begin
        result <= (others => '0');
        less_than_flag <= '0';
        
        if signed_comp = '1' then
            a_ext <= a(31) & a;
            b_ext <= b(31) & b;
        else
            a_ext <= '0' & a;
            b_ext <= '0' & b;
        end if;

        case op is

            when "000" => --ADD/SUB
                if sub_ArShift = '0' then
                    result <= std_logic_vector(unsigned(a) + unsigned(b));
                else
                    intermediate_result <= std_logic_vector(signed(a_ext) - signed(b_ext));
                    less_than_flag <= intermediate_result(31);
                    result <= intermediate_result(31 downto 0);
                end if;
            
            when "001" => --SLL
                result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(shamt))));

            when "010" => --SLT
                result <= x"00000001" when signed(a) < signed(b) else x"00000000";
            
            when "011" => --SLTU
                result <= x"00000001" when unsigned(a) < unsigned(b) else x"00000000";

            when "100" => -- XOR
                result <= a xor b;
            
            when "101" => --SRL/SRA
                if sub_arShift = '0' then
                    result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(shamt))));
                else
                    -- Casting to 'signed' forces shift_right to perform an arithmetic shift (preserves the sign bit)
                    result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(shamt))));
                end if;

            when "110" => --OR
                result <= a or b;

            when "111" => -- AND
                result <= a and b;
            
            when others => result <= x"00000000";
            end case;
        end process;
            
end rtl;
