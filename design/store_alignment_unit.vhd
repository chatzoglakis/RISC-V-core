library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity store_alignment_unit is
    port(
        funct3: in STD_LOGIC_VECTOR(2 downto 0);
        alu_out: in STD_LOGIC_VECTOR(31 downto 0);
        reg_out2: in STD_LOGIC_VECTOR(31 downto 0);
        is_store_inst: in STD_LOGIC; -- Comes from the Control Unit
        ram_data_in: out STD_LOGIC_VECTOR(31 downto 0);
        data_ram_we: out STD_LOGIC_VECTOR(3 downto 0);
        vram_we: out STD_LOGIC
    );
end store_alignment_unit;

architecture rtl of store_alignment_unit is
begin
    process(all)
        variable byte_offset : STD_LOGIC_VECTOR(1 downto 0);
    begin
        byte_offset := alu_out(1 downto 0);
        
        data_ram_we <= "0000";
        vram_we <= '0';
        ram_data_in <= reg_out2;

        if is_store_inst = '1' then
            if alu_out(30) = '0' then --DATA RAM STORE

                case funct3 is
                when "000" => -- SB
                    -- Replicate the lowest 8 bits 4 times
                    ram_data_in <= reg_out2(7 downto 0) & reg_out2(7 downto 0) & reg_out2(7 downto 0) & reg_out2(7 downto 0);

                    case byte_offset is
                        when "00" => data_ram_we <= "0001";
                        when "01" => data_ram_we <= "0010";
                        when "10" => data_ram_we <= "0100";
                        when others => data_ram_we <= "1000";
                    end case;

                when "001" => -- SH
                    -- Replicate the lowest 16 bits 2 times
                    ram_data_in <= reg_out2(15 downto 0) & reg_out2(15 downto 0);
                    if byte_offset(1) = '0' then
                        data_ram_we <= "0011";
                    else
                        data_ram_we <= "1100";
                    end if;

                when "010" => -- SW
                    ram_data_in <= reg_out2;
                    data_ram_we <= "1111";
                    
                when others => 
                    data_ram_we <= "0000";
                end case;

            else --VRAM STORE
                vram_we <= '1';
            end if;
        end if;
    end process;
end rtl;
