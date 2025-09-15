library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.HexDisplayPackage.all;

entity UartLoopback is
    generic
        ( clocks_per_bit : integer := 217 -- Clock Frequency / UART Frequency = floor(25 MHz / 115200 Hz)
        );
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
end entity UartLoopback;

architecture Rtl of UartLoopback is
    signal displayed : unsigned(7 downto 0);
    signal segments  : SegmentsArray;

    signal rx_valid : std_logic;
    signal rx_byte  : std_logic_vector(7 downto 0);
begin
    led1        <= '0';
    led2        <= '0';
    led3        <= '0';
    led4        <= '0';

    display : entity work.HexDisplay port map
        ( clock    => clock
        , binary   => displayed
        , segments => segments
        );

    (segment_2g, segment_2f, segment_2e, segment_2d, segment_2c, segment_2b, segment_2a) <= segments(0);
    (segment_1g, segment_1f, segment_1e, segment_1d, segment_1c, segment_1b, segment_1a) <= segments(1);

    uart_deserialize : entity work.UartDeserialize
        generic map (clocks_per_bit => clocks_per_bit)
        port map
            ( clock      => clock
            , uart_rx    => uart_rx
            , byte_valid => rx_valid
            , byte       => rx_byte
            );

    uart_serialize : entity work.UartSerialize
        generic map (clocks_per_bit => clocks_per_bit)
        port map
            ( clock      => clock
            , byte_valid => rx_valid
            , input_byte => rx_byte
            , uart_tx    => uart_tx
            );

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

    process (clock) is begin
        if rising_edge(clock) then
            if rx_valid = '1' then
                displayed <= unsigned(rx_byte);
            end if;
        end if;
    end process;
end architecture Rtl;
