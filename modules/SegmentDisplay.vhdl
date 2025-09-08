-- Convert binary to a hex digit on a seven segment display.
-- The output segments are 0 when they should be bright and 1 when they should be dim.
-- The segments are arranged as follows:
--     ┌───────────┐
--     │     0     │
-- ┌───┼───────────┼───┐
-- │   │           │   │
-- │ 5 │           │ 1 │
-- │   │           │   │
-- └───┼───────────┼───┘
--     │     6     │
-- ┌───┼───────────┼───┐
-- │   │           │   │
-- │ 4 │           │ 2 │
-- │   │           │   │
-- └───┼───────────┼───┘
--     │     3     │
--     └───────────┘

library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity SegmentDisplay is
    port
        ( clock    : in  std_logic
        ; binary   : in  unsigned(3 downto 0)
        ; segments : out std_logic_vector(6 downto 0)
        );
end entity SegmentDisplay;

architecture Rtl of SegmentDisplay is begin
    -- Only output on rising edges to remove glitches.
    process (clock) is begin
        if rising_edge(clock) then
            case binary is
                when to_unsigned(0, 4)  => segments <= "1000000";
                when to_unsigned(1, 4)  => segments <= "1111001";
                when to_unsigned(2, 4)  => segments <= "0100100";
                when to_unsigned(3, 4)  => segments <= "0110000";
                when to_unsigned(4, 4)  => segments <= "0011001";
                when to_unsigned(5, 4)  => segments <= "0010010";
                when to_unsigned(6, 4)  => segments <= "0000010";
                when to_unsigned(7, 4)  => segments <= "1111000";
                when to_unsigned(8, 4)  => segments <= "0000000";
                when to_unsigned(9, 4)  => segments <= "0011000";
                when to_unsigned(10, 4) => segments <= "0001000";
                when to_unsigned(11, 4) => segments <= "0000011";
                when to_unsigned(12, 4) => segments <= "1000110";
                when to_unsigned(13, 4) => segments <= "0100001";
                when to_unsigned(14, 4) => segments <= "0000110";
                when to_unsigned(15, 4) => segments <= "0001110";
                when others             => segments <= "1111111";
            end case;
        end if;
    end process;
end architecture Rtl;
