library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vga_controller is
    port(
        clk, rst: in STD_LOGIC;
        hsync: out STD_LOGIC;
        vsync: out STD_LOGIC;
        pixel_x: out STD_LOGIC_VECTOR(9 downto 0);
        pixel_y : out std_logic_vector (9 downto 0);
        video_on: out STD_LOGIC
    );
end vga_controller;

architecture rtl of vga is

    signal v_count: STD_LOGIC_VECTOR(9 downto 0);
    signal h_count: STD_LOGIC_VECTOR(9 downto 0);
    signal v_sync_reg: STD_LOGIC;
    signal h_sync_reg : std_logic ;

begin

    process(clk, rst) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                h_count <= (others => '0');
                v_count <= (others => '0');
                h_sync_reg <= '1';
                v_sync_reg <= '1';
            else
                

                --COUNTERS
                if unsigned(h_count) = 799 then
                    h_count <= (others => '0');
                    
                    -- Vertical counter ONLY increments when the row finishes!
                    if unsigned(v_count) = 524 then
                        v_count <= (others => '0');
                    else
                        v_count <= STD_LOGIC_VECTOR(unsigned(v_count) + 1);
                    end if;
                    
                else
                    h_count <= STD_LOGIC_VECTOR(unsigned(h_count) + 1);
                end if;

                --SYNC SIGNALS
                if unsigned(h_count) > 663 and unsigned(h_count) < 760 then
                    h_sync_reg <= '0';
                else
                    h_sync_reg <= '1';
                end if;

                if unsigned(v_count) > 489 and unsigned(v_count) < 492 then
                    v_sync_reg <= '0';
                else
                    v_sync_reg <= '1';
                end if;
                
            end if;
        end if;
    end process;

    video_on <= '1' when (unsigned(h_count) < 640 and unsigned(v_count) < 480) else '0';

    hsync <= h_sync_reg;
    vsync <= v_sync_reg;
    pixel_x <= h_count;
    pixel_y <= v_count;

end rtl;
