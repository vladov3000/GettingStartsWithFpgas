library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram2Port is
    generic
        ( WIDTH : integer := 16
        ; DEPTH : integer := 256
        );
    port
        ( write_clock      : in  std_logic
        ; write_address    : in  std_logic_vector
        ; write_data_valid : in  std_logic
        ; write_data       : in  std_logic_vector(WIDTH - 1 downto 0)

        ; read_clock       : in  std_logic
        ; read_address     : in  std_logic_vector
        ; read_enable      : in  std_logic
        ; read_data_valid  : out std_logic
        ; read_data        : out std_logic_vector(WIDTH - 1 downto 0)
        );
end entity Ram2Port;

architecture Rtl for Ram2Prot is
    signal memory : array (0 to DEPTH - 1) of std_logic_vector (WIDTH - 1 downto 0);
begin
    process (write_clock) begin
        if rising_edge(write_clock) then
            if write_data_valid = '1' then
                memory(to_integer(unsigned(write_address))) <= write_data;
            end if;
        end if;
    end process;

    process (read_clock) begin
        if rising_edge(read_clock) begin
            read_data <= memory(to_integer(unsigned(read_address)));
            read_data_valid <= read_enable;
        end if;
    end process;
end architecture Rtl;
