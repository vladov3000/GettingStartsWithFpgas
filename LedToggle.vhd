library ieee;

use ieee.std_logic_1164.all;

entity LedToggle is
    port
        ( clock   : in  std_logic
        ; switch1 : in  std_logic
        ; led1    : out std_logic
        );
end entity LedToggle;

architecture Default of LedToggle is
    signal state_led1    : std_logic := '0';
    signal state_switch1 : std_logic := '0';
begin
    process (clock) is begin
        if rising_edge(clock) then
            state_switch1 <= switch1;

            if switch1 = '0' and state_switch1 = '1' then
                state_led1 <= not state_led1
            end if;
        end if;
    end process;

    led1 <= state_led1;
end architecture Default;
