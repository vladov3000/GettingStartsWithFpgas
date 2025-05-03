library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debouncer is
    port
        ( clock   : in  std_logic
        ; switch1 : in  std_logic
        ; led1    : out std_logic
        );
end entity Debouncer;

architecture Default of Debouncer is
    signal debounced_switch : std_logic;
begin
    DebounceFilter : entity work.DebounceFilter
        generic map ( LIMIT => 250000 )
        port map
            ( clock     => clock
            , bouncy    => switch1
            , debounced => debounced_switch
            );
    
    LedToggle : entity work.LedToggle
        port map
            ( clock   => clock
            , switch1 => debounced_switch
            , led1    => led1
            );
end architecture Default;

entity DebounceFilter is
    generic ( LIMIT : integer );
    port
        ( clock     : in std_logic;
        ; bouncy    : in std_logic;
        ; debounced : out std_logic;
        );
end entity DebounceFilter;

architecture Default of DebounceFilter is
    signal count : integer range 0 to LIMIT := 0;
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
