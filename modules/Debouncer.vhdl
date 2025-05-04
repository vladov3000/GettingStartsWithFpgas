library ieee;

use ieee.std_logic_1164.all;

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
        generic map (LIMIT => 250000)
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
