library ieee;

use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Fifo is
    generic
        ( width : integer := 16
        ; depth : integer := 256
        );
    port
        ( clock              : in  std_logic
        ; reset              : in  std_logic

        ; write_data_valid   : in  std_logic
        ; write_data         : in  std_logic_vector(width - 1 downto 0)
        ; almost_full_level  : in  integer
        ; almost_full        : out std_logic
        ; full               : out std_logic

        ; read_enable        : in  std_logic
        ; read_data_valid    : out std_logic
        ; read_data          : out std_logic_vector(width - 1 downto 0)
        ; almost_empty_level : in  integer
        ; almost_empty       : out std_logic
        ; empty              : out std_logic
        );
end entity Fifo;

architecture Rtl of Fifo is
    subtype Address is natural range 0 to depth - 1;

    signal write_address : Address;
    signal read_address  : Address;
    signal count         : natural range 0 to depth;
begin
    ram : entity work.Ram2Port
        generic map
            ( width => width
            , depth => depth
            )
        port map
            ( write_clock      => clock
            , write_address    => write_address
            , write_data_valid => write_data_valid
            , write_data       => write_data

            , read_clock       => clock
            , read_address     => read_address
            , read_enable      => read_enable
            , read_data_valid  => read_data_valid
            , read_data        => read_data
            );

    process (clock, reset) begin
        if not reset then
            write_address <= 0;
            read_address  <= 0;
            count         <= 0;
        elsif rising_edge(clock) then
            if write_data_valid then
                if write_address = depth - 1 then
                    write_address <= 0;
                else
                    write_address <= write_address + 1;
                end if;
            end if;

            if read_enable then
                if read_address = depth - 1 then
                    read_address <= 0;
                else
                    read_address <= read_address + 1;
                end if;
            end if;

            if read_enable = '1' and write_data_valid = '0' then
                if count /= 0 then
                    count <= count - 1;
                end if;
            elsif write_data_valid = '1' and read_enable = '0' then
                if count = depth then
                    count <= count + 1;
                end if;
            end if;
        end if;

        almost_full  <= '1' when count > depth - almost_full_level else '0';
        almost_empty <= '1' when count < almost_empty_level        else '0';

        full  <= '1' when count = depth or (count = depth - 1 and write_data_valid = '1' and read_enable = '0') else '0';
        empty <= '1' when count = 0 else '0';
    end process;
end architecture Rtl;
