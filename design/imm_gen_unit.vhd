library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imm_gen_unit is
    port(
        instruction: in STD_LOGIC_VECTOR(31 downto 0);
        imm_sel: in STD_LOGIC_VECTOR(2 downto 0);
        immediate: out STD_LOGIC_VECTOR(31 downto 0)
    );
end imm_gen_unit;

architecture rtl of imm_gen_unit is

begin
    
    process(all)
    begin
         case imm_sel is
            when "000" => --I-Type
                immediate <= (31 downto 11 => instruction(31)) & instruction(30 downto 20);

            when "001" => --S-Type
                immediate <= (31 downto 11 => instruction(31)) & instruction(30 downto 25) & instruction(11 downto 7);

            when "010" => --B-Type
                immediate <= (31 downto 12 => instruction(31)) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';

            when "011" => --U-Type
                immediate <= instruction(31 downto 12) & (11 downto 0 => '0');

            when "100" => --J-Type
                immediate <= (31 downto 20 => instruction(31)) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';
            
            when others => immediate <= x"00000000";
         end case;
    end process;

end rtl;
