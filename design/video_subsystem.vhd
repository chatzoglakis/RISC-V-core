library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity video_subsystem is
    port(
        clk_90, clk_25, rst: in STD_LOGIC;
        vram_we: in STD_LOGIC;
        write_address: in STD_LOGIC_VECTOR(17 downto 0);
        vram_data_in: in STD_LOGIC_VECTOR(7 downto 0);
        swap_trigger: in STD_LOGIC;
        hsync, vsync: out STD_LOGIC;
        vga_status: out STD_LOGIC;
        r, g, b: out STD_LOGIC_VECTOR(3 downto 0)
    );
end video_subsystem;

architecture rtl of video_subsystem is

    signal read_address: STD_LOGIC_VECTOR(17 downto 0);
    signal pixel_data: STD_LOGIC_VECTOR(7 downto 0);
    signal async_swap_request: STD_LOGIC := '0';
    signal sync_swap_request: STD_LOGIC := '0';
    signal async_swap_ack: STD_LOGIC := '0';
    signal sync_swap_ack: STD_LOGIC := '0';


begin

    vram: entity work.vram
     port map(
        clk_a => clk_90,
        we_a => vram_we,
        address_a => write_address,
        data_a => vram_data_in,
        clk_b => clk_25,
        address_b => read_address,
        data_b => pixel_data
    );

    framebuffer_swap_request: process(clk_90)   
    begin
        if rising_edge(clk_90) then
            if rst = '1' then
                async_swap_request <= '0';
            elsif swap_trigger = '1' then
                async_swap_request <= not async_swap_request;
            end if;
        end if;
    end process;

    swap_request_synchronizer: entity work.two_ff_synchronizer
     port map(
        clk => clk_25,
        rst => rst,
        async_data => async_swap_request,
        sync_data => sync_swap_request
    );

    vga_controller: entity work.vga_controller
     port map(
        clk => clk_25,
        rst => rst,
        swap_request => sync_swap_request,
        swap_ack => async_swap_ack,
        pixel_data => pixel_data,
        hsync => hsync,
        vsync => vsync,
        read_address => read_address,
        r => r,
        g => g,
        b => b
    );

    swap_ack_synchronizer: entity work.two_ff_synchronizer
     port map(
        clk => clk_90,
        rst => rst,
        async_data => async_swap_ack,
        sync_data => sync_swap_ack
    );
    
    vga_status <= '0' when async_swap_request = sync_swap_ack else '1';

end rtl;
