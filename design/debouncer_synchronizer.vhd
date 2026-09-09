library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer_synchronizer is
    port(
        clk: in STD_LOGIC;
        rst: in std_logic;
        btn_in: in STD_LOGIC;
        btn_state: out STD_LOGIC
    );
end debouncer_synchronizer;

architecture rtl of debouncer_synchronizer is

constant C_SHIFT_LEN: integer := 16;
constant MAX_TICKS: integer := 9000;

signal tick_count: integer range 0 to MAX_TICKS := 0;
signal ce: STD_LOGIC;
signal sync_btn: STD_LOGIC;
signal shift_reg: std_logic_vector(C_SHIFT_LEN-1 downto 0);
signal debounced: std_logic;

begin

    two_ff_synchronizer: entity work.two_ff_synchronizer
     port map(
        clk => clk,
        rst => rst,
        async_data => btn_in,
        sync_data => sync_btn
    );
    
    clk_en: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tick_count <= 0;
                ce <= '0';
            else
                if tick_count < MAX_TICKS then
                    ce <= '0';
                    tick_count <= tick_count + 1;
                else
                    ce <= '1';
                    tick_count <= 0;
                end if;
            end if;
        end if;
    end process;

    p_debounce: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_reg <= (others => '0');
                debounced <= '0';
            else
                if ce = '1' then
                    -- Shift values to the left and load a new sample as LSB
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync_btn;

                    -- Check if all bits are '1'
                    if shift_reg = (shift_reg'range => '1') then
                        debounced <= '1';
                    -- Check if all bits are '0'
                    elsif shift_reg = (shift_reg'range => '0') then
                    debounced <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    btn_state <= debounced;
end rtl;
