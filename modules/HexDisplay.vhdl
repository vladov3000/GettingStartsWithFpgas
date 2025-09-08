library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package HexDisplayPackage is
    type SegmentsArray is array (0 to 1) of std_logic_vector(6 downto 0);
end package;

library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.HexDisplayPackage.all;

entity HexDisplay is
    port
        ( clock    : in  std_logic
        ; binary   : in  unsigned(7 downto 0)
        ; segments : out SegmentsArray
        );
end entity HexDisplay;

architecture Rtl of HexDisplay is begin
    displays : for i in 0 to 1 generate begin
        display : entity work.SegmentDisplay port map
            ( clock    => clock
            , binary   => binary(4 * i + 3 downto 4 * i)
            , segments => segments(i)
            );
    end generate;
end architecture Rtl;
