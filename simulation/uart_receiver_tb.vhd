library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_receiver_tb is
end uart_receiver_tb;

architecture Behavioral of uart_receiver_tb is

    constant CLK_PERIOD: time := 10 ns; 

    signal clk: STD_LOGIC;
    signal rx: STD_LOGIC;
    signal done: STD_LOGIC;
    signal data: STD_LOGIC_VECTOR(7 downto 0);

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

        --sending number 0xFF
        for j in 0 to 7 loop
            rx <= '1';
            wait for 20 ns;
        end loop;
            
        wait until done = '0' for 500 ns;
        assert data = x"FF" report "FAILED TO RECEIVE DATA" severity error;
           
        std.env.finish;
    end process;

end Behavioral;
