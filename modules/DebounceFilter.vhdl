library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DebounceFilter is
    generic (LIMIT : integer);
    port
        ( clock     : in  std_logic
        ; bouncy    : in  std_logic
        ; debounced : out std_logic
        );
end entity DebounceFilter;

architecture Default of DebounceFilter is
    signal count : integer range 0 to LIMIT - 1 := 0;
    signal state : std_logic := '0';
begin
    process (clock) is begin
        if rising_edge(clock) then
            if (bouncy /= state and count < LIMIT - 1) then
                count <= count + 1;
            elsif count = LIMIT - 1 then
                state <= bouncy;
                count <= 0;
            else
                count <= 0;
            end if;
        end if;
    end process;

    debounced <= state;
end architecture Default;
