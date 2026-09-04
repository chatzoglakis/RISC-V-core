library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vga_controller is
    port(
        clk, rst: in STD_LOGIC;
        pixel_data: in STD_LOGIC_VECTOR(7 downto 0);
        hsync: out STD_LOGIC;
        vsync: out STD_LOGIC;
        read_address: out STD_LOGIC_VECTOR(17 downto 0);
        r,g,b: out STD_LOGIC_VECTOR(3 downto 0)
    );
end vga_controller;

architecture rtl of vga_controller is

    signal pixel_x: STD_LOGIC_VECTOR(8 downto 0);
    signal pixel_y : std_logic_vector (8 downto 0);

    signal v_count: STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal h_count: STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal v_sync_reg: STD_LOGIC;
    signal h_sync_reg : std_logic ;
    signal video_on: STD_LOGIC;
    signal framebuffer_sel: STD_LOGIC := '0';
    signal pixel_addr_math : unsigned(16 downto 0);

begin

    sync_proc:process(clk, rst) is
    begin
        if rising_edge(clk) then

            if rst = '1' then
                h_count <= (others => '0');
                v_count <= (others => '0');
                h_sync_reg <= '1';
                v_sync_reg <= '1';
                framebuffer_sel <= '0';
            else
                

                --COUNTERS
                if unsigned(h_count) = 799 then
                    h_count <= (others => '0');
                    
                    if unsigned(v_count) = 524 then
                        v_count <= (others => '0');
                    else
                        v_count <= STD_LOGIC_VECTOR(unsigned(v_count) + 1);
                    end if;

                    --change framebuffer when the whole screen has been "painted"
                    if unsigned(v_count) = 479 then
                        framebuffer_sel <= not framebuffer_sel;
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
    -- Drop the lowest bit to scale 640x480 down to 320x240
    pixel_x <= h_count(9 downto 1);
    pixel_y <= v_count(9 downto 1);

    -- Calculate (Y * 256) + (Y * 64) + X
    pixel_addr_math <= unsigned(pixel_y & "00000000") + 
                       unsigned(pixel_y & "000000") + 
                       unsigned(pixel_x);

    read_address <= framebuffer_sel & STD_LOGIC_VECTOR(pixel_addr_math);

    coloring_proc:process(clk, rst) is
    begin
        if rst = '1' then
            r <= "0000";
            g <= "0000";
            b <= "0000";
        elsif rising_edge(clk) then
            if video_on = '1' then            
                -- RED:   Take top 3 bits, duplicate bit 7 at the bottom
                r <= pixel_data(7 downto 5) & pixel_data(7);
                
                -- GREEN: Take next 3 bits, duplicate bit 4 at the bottom
                g <= pixel_data(4 downto 2) & pixel_data(4);
                
                -- BLUE:  Take bottom 2 bits, duplicate them to make 4 bits
                b <= pixel_data(1 downto 0) & pixel_data(1 downto 0);
            else
                r <= "0000";
                g <= "0000";
                b <= "0000";
            end if;
        end if;
    end process;

end rtl;
