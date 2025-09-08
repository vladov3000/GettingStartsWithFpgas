library ieee;

use ieee.std_logic_1164.all;

entity NullTop is
    port ( clock       : in    std_logic
         ; led1        : out   std_logic
         ; led2        : out   std_logic
         ; led3        : out   std_logic
         ; led4        : out   std_logic
         ; switch1     : in    std_logic
         ; switch2     : in    std_logic
         ; switch3     : in    std_logic
         ; switch4     : in    std_logic
         ; segment_1a  : out   std_logic
         ; segment_1b  : out   std_logic
         ; segment_1c  : out   std_logic
         ; segment_1d  : out   std_logic
         ; segment_1e  : out   std_logic
         ; segment_1f  : out   std_logic
         ; segment_1g  : out   std_logic
         ; segment_2a  : out   std_logic
         ; segment_2b  : out   std_logic
         ; segment_2c  : out   std_logic
         ; segment_2d  : out   std_logic
         ; segment_2e  : out   std_logic
         ; segment_2f  : out   std_logic
         ; segment_2g  : out   std_logic
         ; uart_rx     : in    std_logic
         ; uart_tx     : out   std_logic
         ; vga_hsync   : out   std_logic
         ; vga_vsync   : out   std_logic
         ; vga_red_0   : out   std_logic
         ; vga_red_1   : out   std_logic
         ; vga_red_2   : out   std_logic
         ; vga_green_0 : out   std_logic
         ; vga_green_1 : out   std_logic
         ; vga_green_2 : out   std_logic
         ; vga_blue_0  : out   std_logic
         ; vga_blue_1  : out   std_logic
         ; vga_blue_2  : out   std_logic
         ; pmod_1      : inout std_logic
         ; pmod_2      : inout std_logic
         ; pmod_3      : inout std_logic
         ; pmod_4      : inout std_logic
         ; pmod_7      : inout std_logic
         ; pmod_8      : inout std_logic
         ; pmod_9      : inout std_logic
         ; pmod_10     : inout std_logic
         );
end entity NullTop;

architecture Rtl of NullTop is begin
    led1        <= '0';
    led2        <= '0';
    led3        <= '0';
    led4        <= '0';
    segment_1a  <= '1';
    segment_1b  <= '1';
    segment_1c  <= '1';
    segment_1d  <= '1';
    segment_1e  <= '1';
    segment_1f  <= '1';
    segment_1g  <= '1';
    segment_2a  <= '1';
    segment_2b  <= '1';
    segment_2c  <= '1';
    segment_2d  <= '1';
    segment_2e  <= '1';
    segment_2f  <= '1';
    segment_2g  <= '1';
    uart_tx     <= '0';
    vga_hsync   <= '0';
    vga_vsync   <= '0';
    vga_red_0   <= '0';
    vga_red_1   <= '0';
    vga_red_2   <= '0';
    vga_green_0 <= '0';
    vga_green_1 <= '0';
    vga_green_2 <= '0';
    vga_blue_0  <= '0';
    vga_blue_1  <= '0';
    vga_blue_2  <= '0';
    pmod_1      <= 'Z';
    pmod_2      <= 'Z';
    pmod_3      <= 'Z';
    pmod_4      <= 'Z';
    pmod_7      <= 'Z';
    pmod_8      <= 'Z';
    pmod_9      <= 'Z';
    pmod_10     <= 'Z';
end architecture Rtl;
