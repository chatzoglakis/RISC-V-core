library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity data_loading_unit is
    port(
        data_mem_out: in STD_LOGIC_VECTOR(31 downto 0);
        byte_offset: in STD_LOGIC_VECTOR(1 downto 0);
        funct3: in STD_LOGIC_VECTOR(2 downto 0);
        mem_writeback_data: out STD_LOGIC_VECTOR(31 downto 0)
    );
end data_loading_unit;

architecture rtl of data_loading_unit is

    pure function extract_byte(byte_offset: STD_LOGIC_VECTOR(1 downto 0);
                               data_mem_out: STD_LOGIC_VECTOR(31 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        case byte_offset is
            when "00" => return data_mem_out(7 downto 0);
            when "01" => return data_mem_out(15 downto 8);
            when "10" => return data_mem_out(23 downto 16);
            when others => return data_mem_out(31 downto 24);
        end case;
    end function;

    pure function extract_halfword(byte_offset: STD_LOGIC_VECTOR(1 downto 0);
                                   data_mem_out: STD_LOGIC_VECTOR(31 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        case byte_offset(1) is
            when '0' => return data_mem_out(15 downto 0);
            when others => return data_mem_out(31 downto 16);
        end case;
    end function;

begin

    load_from_ram_proc: process(all)
        variable extracted_byte : STD_LOGIC_VECTOR(7 downto 0);
        variable extracted_half : STD_LOGIC_VECTOR(15 downto 0);
    begin
        mem_writeback_data <= data_mem_out;

        case funct3 is
            when "000" => --LB
                extracted_byte := extract_byte(byte_offset, data_mem_out);
                mem_writeback_data <= (31 downto 8 => extracted_byte(7)) & extracted_byte;
            
            when "001" => --LH
                extracted_half := extract_halfword(byte_offset, data_mem_out);
                mem_writeback_data <= (31 downto 16 => extracted_half(15)) & extracted_half;

            when "100" => --LBU
                extracted_byte := extract_byte(byte_offset, data_mem_out);
                mem_writeback_data <= (31 downto 8 => '0') & extracted_byte;

            when "101" => --LHU
                extracted_half := extract_halfword(byte_offset, data_mem_out);
                mem_writeback_data <= (31 downto 16 => '0') & extracted_half;

            when others => null;

        end case;
    end process;

end rtl;
