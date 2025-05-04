library ieee;

use ieee.std_logic_1164.all;

entity SelectiveBlink is
    port
        ( clock   : in  std_logic
        ; switch1 : in  std_logic
        ; switch2 : in  std_logic
        ; led1    : out std_logic
        ; led2    : out std_logic
        ; led3    : out std_logic
        ; led4    : out std_logic
        );
end entity SelectiveBlink;

architecture Rtl of SelectiveBlink is
    signal toggle : std_logic := '0';
    signal done   : std_logic := '0';
begin
    lfsr : entity work.Lfsr port map
        ( clock => clock
        , data  => open
        , done  => done
        );

    process (clock) is begin
        if rising_edge(clock) then
            if done = '1' then
                toggle <= not toggle;
            end if;
        end if;
    end process;

    demux : entity work.Demux port map
        ( data    => toggle
        , select0 => switch1
        , select1 => switch2
        , data0   => led1
        , data1   => led2
        , data2   => led3
        , data3   => led4
        );
end architecture Rtl;
