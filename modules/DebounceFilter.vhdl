library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DebounceFilter is
    generic (limit : integer := 5);
    port
        ( clock     : in  std_logic
        ; bouncy    : in  std_logic
        ; debounced : out std_logic
        );
end entity DebounceFilter;

architecture Rtl of DebounceFilter is
    constant max_count : integer := limit - 1;

    signal count : integer range 0 to max_count := 0;
    signal state : std_logic := '0';
begin
    process (clock) is begin
        if rising_edge(clock) then
            if (bouncy /= state and count < max_count) then
                count <= count + 1;
            elsif count = max_count then
                state <= bouncy;
                count <= 0;
            else
                count <= 0;
            end if;
        end if;
    end process;

    debounced <= state;
end architecture Rtl;
