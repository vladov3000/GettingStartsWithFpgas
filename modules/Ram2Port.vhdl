library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram2Port is
    generic
        ( width : integer := 16
        ; depth : integer := 256
        );

    port
        ( write_clock      : in  std_logic
        ; write_address    : in  natural range 0 to depth - 1
        ; write_data_valid : in  std_logic
        ; write_data       : in  std_logic_vector(width - 1 downto 0)

        ; read_clock       : in  std_logic
        ; read_address     : in  natural range 0 to depth - 1
        ; read_enable      : in  std_logic
        ; read_data_valid  : out std_logic
        ; read_data        : out std_logic_vector(width - 1 downto 0)
        );
end entity Ram2Port;

architecture Rtl of Ram2Port is
    type MemoryType is array (0 to depth - 1) of std_logic_vector (width - 1 downto 0);
    signal memory : MemoryType;
begin
    process (write_clock) begin
        if rising_edge(write_clock) then
            if write_data_valid = '1' then
                memory(write_address) <= write_data;
            end if;
        end if;
    end process;

    process (read_clock) begin
        if rising_edge(read_clock) then
            read_data <= memory(read_address);
            read_data_valid <= read_enable;
        end if;
    end process;
end architecture Rtl;
