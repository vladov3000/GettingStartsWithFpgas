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

architecture Default for SelectiveBlink
    signal toggle : std_logic := '0';
    signal done   : std_logic;
begin
    lfsr : entity work.Lsfr port map
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
end architecture Default;

entity Lfsr is
    port
        ( clock : in  std_logic
        ; data  : out std_logic_vector(21 downto 0)
        ; done  : out std_logic
        );
end entity Lfsr;

architecture Rtl for Lfsr
    signal lfsr : std_logic_vector(21 downto 0);
    signal lsb  : std_logic;
begin
    process (clock) begin
        if rising_edge (clock) then
            lfsr <= lfsr(20 downto 0) & lsb;
        end if;
    end process;

    lsb  <= lfsr(21) xnor lfsr(20);
    done <= '1' when (lfsr = "0000000000000000000000") else '0';
    data <= lfsr;
end architecture Rtl;

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

architecture Rtl for Demux begin
    data0 <= data when select1 = '0' and select0 = '0' else 0;
    data1 <= data when select1 = '0' and select0 = '1' else 0;
    data2 <= data when select1 = '1' and select0 = '0' else 0;
    data3 <= data when select1 = '1' and select0 = '1' else 0;
end architecture Rtl;
