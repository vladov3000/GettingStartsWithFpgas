-- Run the game with:
-- $ ./build.sh --program modules/MemoryGame.vhdl modules/SegmentDisplay.vhdl modules/DebounceFilter.vhdl modules/HexDisplay.vhdl modules/MemoryGame/StateMachine.vhdl modules/Lfsr.vhdl modules/CountAndToggle.vhdl
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.HexDisplayPackage.all;

entity MemoryGame is
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
end entity MemoryGame;

architecture Rtl of MemoryGame is
    signal switches           : std_logic_vector(3 downto 0);
    signal debounced_switches : std_logic_vector(3 downto 0);

    signal score : unsigned(3 downto 0);
    signal leds  : std_logic_vector(3 downto 0);

    signal segments : SegmentsArray;
begin
    switches <= switch4 & switch3 & switch2 & switch1;

    debouncers : for i in switches'range generate begin
        debouncer : entity work.DebounceFilter
            generic map (limit => 250000) -- 10 ms
            port map
                ( clock     => clock
                , bouncy    => switches(i)
                , debounced => debounced_switches(i)
                );
    end generate;

    state_machine : entity work.StateMachine port map
        ( clock    => clock
        , switches => debounced_switches
        , score    => score
        , leds     => leds
        );

    (led4, led3, led2, led1) <= leds;

    display : entity work.HexDisplay port map
        ( clock    => clock
        , binary   => resize(score, 8)
        , segments => segments
        );

    -- The second segment display is on the right, we map it to the least significant digit.
    (segment_2g, segment_2f, segment_2e, segment_2d, segment_2c, segment_2b, segment_2a) <= segments(0);
    (segment_1g, segment_1f, segment_1e, segment_1d, segment_1c, segment_1b, segment_1a) <= segments(1);

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
