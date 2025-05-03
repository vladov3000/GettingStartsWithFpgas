library ieee;

use ieee.std_logic_1164.all;

entity AndGate is
    port
        ( switch1 : in  std_logic
        ; switch2 : in  std_logic
        ; led1    : out std_logic
        );
end entity AndGate;

architecture Default of AndGate is begin
    led1 <= switch1 and switch2;
end architecture Default;
