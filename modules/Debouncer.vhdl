library ieee;

use ieee.std_logic_1164.all;

entity Debouncer is
    generic (limit : integer := 250000);
    port
        ( clock   : in  std_logic
        ; switch1 : in  std_logic
        ; led1    : out std_logic
        );
end entity Debouncer;

architecture Rtl of Debouncer is
    signal debounced : std_logic;
begin
    DebounceFilter : entity work.DebounceFilter
        generic map (limit => limit)
        port map
            ( clock     => clock
            , bouncy    => switch1
            , debounced => debounced
            );
    
    LedToggle : entity work.LedToggle
        port map
            ( clock   => clock
            , switch1 => debounced
            , led1    => led1
            );
end architecture Rtl;
