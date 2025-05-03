library ieee;

use ieee.std_logic_1164.all;

entity SwitchesToLeds is
   port (switch1  : in  std_logic
        ; switch2 : in  std_logic
        ; switch3 : in  std_logic
        ; switch4 : in  std_logic
        ; led1    : out std_logic
        ; led2    : out std_logic
        ; led3    : out std_logic
        ; led4    : out std_logic
        );
end entity SwitchesToLeds;

architecture Default of SwitchesToLeds is begin
    led1 <= switch1;
    led2 <= switch2;
    led3 <= switch3;
    led4 <= switch4;
end architecture Default;
