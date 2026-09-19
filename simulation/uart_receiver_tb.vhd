library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_receiver_tb is
end uart_receiver_tb;

architecture Behavioral of uart_receiver_tb is

    constant CLK_PERIOD: time := 10 ns; 

    signal clk: STD_LOGIC;
    signal rx: STD_LOGIC;
    signal done: STD_LOGIC;
    signal data: STD_LOGIC_VECTOR(31 downto 0);

begin

    uut: entity work.uart_receiver
     port map(
        clk => clk,
        rx => rx,
        done => done,
        data => data
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
        --initialization
        rx <= '1';
        wait for 100 ns;
        --start bit
        rx <= '0';
        wait for 20 ns;

        --sending number 01000011100000000000000010000001 (0x43800081)
        for i in 0 to 31 loop
            if i = 0 or i = 7 or i = 23 or i = 24 or i = 25 or i = 30 then
                rx <= '1';
            else
                rx <= '0';
            end if;
            wait for 20 ns;
        end loop;
        
        wait until done <= '1';
        assert data = x"43800081" report "FAILED TO RECEIVE DATA" severity error;
        std.env.finish;
    end process;


end Behavioral;
