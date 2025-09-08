library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity CountAndToggle is
    generic (count_limit : natural);
    port ( clock  : in  std_logic
         ; enable : in  std_logic
         ; toggle : out std_logic
         );
end CountAndToggle;

architecture Rtl of CountAndToggle is
    signal counter : natural range 0 to count_limit - 1;
begin
    process (clock) is begin
        if (rising_edge(clock)) then
            if (enable = '1') then
                if (counter = count_limit - 1) then
                    toggle  <= not toggle;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
            else
                toggle <= '0';
            end if;
        end if;
    end process;
end architecture Rtl;
