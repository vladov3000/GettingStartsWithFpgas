library ieee;

use ieee.std_logic_1164.all;

entity Demux is
    port
        ( data    : in  std_logic
        ; select0 : in  std_logic
        ; select1 : in  std_logic
        ; data0   : out std_logic
        ; data1   : out std_logic
        ; data2   : out std_logic
        ; data3   : out std_logic
        );
end entity Demux;

architecture Rtl of Demux is begin
    data0 <= data when select1 = '0' and select0 = '0' else '0';
    data1 <= data when select1 = '0' and select0 = '1' else '0';
    data2 <= data when select1 = '1' and select0 = '0' else '0';
    data3 <= data when select1 = '1' and select0 = '1' else '0';
end architecture Rtl;
