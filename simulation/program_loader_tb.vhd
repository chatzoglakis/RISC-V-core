library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity program_loader_tb is
end program_loader_tb;

architecture Behavioral of program_loader_tb is

    constant CLK_PERIOD: time := 10 ns;
    constant BAUD_PERIOD: time := 20 ns;

    signal clk: STD_LOGIC;
    signal prog_mode: STD_LOGIC;
    signal rx: STD_LOGIC;
    signal instruction: STD_LOGIC_VECTOR(31 downto 0);
    signal address: STD_LOGIC_VECTOR(11 downto 0);
    signal we: STD_LOGIC_VECTOR(3 downto 0);

begin

    dut: entity work.program_loader
     port map(
        clk => clk,
        prog_mode => prog_mode,
        rx => rx,
        instruction => instruction,
        address => address,
        we => we
    );

    clk_proc: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;         
    end process;

    stimuli: process
    begin
        rx <= '1';
        prog_mode <= '0';
        wait for 20 ns;

        prog_mode <= '1';
        rx <= '0';
        wait for 15 ns;
        for i in 0 to 31 loop
            rx <= '1';
            wait for BAUD_PERIOD;
        end loop;
        wait until we = "1111" for 1 ms;
        assert instruction = x"FFFFFFFF" report "FAILED TO LOAD INSTRUCTION" severity error;
        
        wait until we = "0000" for 1 ms;
        assert unsigned(address) = 1 report "FAILED TO CHANGE ADDRESS" severity error;
        
        std.env.finish;
    end process;

end Behavioral;
