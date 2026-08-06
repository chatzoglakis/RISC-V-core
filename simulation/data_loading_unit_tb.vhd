library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_loading_unit_tb is
end data_loading_unit_tb;

architecture Behavioral of data_loading_unit_tb is

    signal data_mem_out: STD_LOGIC_VECTOR(31 downto 0);
    signal byte_offset: STD_LOGIC_VECTOR(1 downto 0);
    signal funct3: STD_LOGIC_VECTOR(2 downto 0);
    signal mem_writeback_data: STD_LOGIC_VECTOR(31 downto 0);

begin

    data_loading_unit: entity work.data_loading_unit
     port map(
        data_mem_out => data_mem_out,
        byte_offset => byte_offset,
        funct3 => funct3,
        mem_writeback_data => mem_writeback_data
    );

    stimuli: process
    begin
        data_mem_out <= x"ABCDE2CE";

        ---------- LOAD BYTE ----------
        report "testing LB (load byte)";
        funct3 <= "000";
        byte_offset <= "00";
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFFFCE" report "LOAD BYTE FAILED" severity error;

        byte_offset <= "01";
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFFFE2" report "LOAD BYTE FAILED" severity error;

        byte_offset <= "10";
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFFFCD" report "LOAD BYTE FAILED" severity error;

        byte_offset <= "11";
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFFFAB" report "LOAD BYTE FAILED" severity error;


        ---------- LOAD HALFWORD ----------
        report "testing LH (load halfword)";
        funct3 <= "001";
        byte_offset(1) <= '0';
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFE2CE" report "LOAD HALFWORD FAILED" severity error;

        byte_offset(1) <= '1';
        wait for 50 ns;
        assert mem_writeback_data = x"FFFFABCD" report "LOAD HALFWORD FAILED" severity error;


        ---------- LOAD BYTE UNSIGNED ----------
        report "testing LBU (load byte unsigned)";
        funct3 <= "100";
        byte_offset <= "00";
        wait for 50 ns;
        assert mem_writeback_data = x"000000CE" report "LOAD BYTE UNSIGNED FAILED" severity error;

        byte_offset <= "01";
        wait for 50 ns;
        assert mem_writeback_data = x"000000E2" report "LOAD BYTE UNSIGNED FAILED" severity error;

        byte_offset <= "10";
        wait for 50 ns;
        assert mem_writeback_data = x"000000CD" report "LOAD BYTE UNSIGNED FAILED" severity error;

        byte_offset <= "11";
        wait for 50 ns;
        assert mem_writeback_data = x"000000AB" report "LOAD BYTE UNSIGNED FAILED" severity error;


        ---------- LOAD HALFWORD UNSIGNED ----------
        report "testing LHU (load halfword unsigned)";
        funct3 <= "101";
        byte_offset(1) <= '0';
        wait for 50 ns;
        assert mem_writeback_data = x"0000E2CE" report "LOAD HALFWORD UNSIGNED FAILED" severity error;

        byte_offset(1) <= '1';
        wait for 50 ns;
        assert mem_writeback_data = x"0000ABCD" report "LOAD HALFWORD UNSIGNED FAILED" severity error;


        ---------- LOAD WORD ----------
        report "testing lw (load word)";
        funct3 <= "010";
        wait for 50 ns;
        assert mem_writeback_data = data_mem_out report "LOAD WORD FAILED" severity error;

    end process;

end Behavioral;
