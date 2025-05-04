library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Lfsr is
    generic (width : integer := 22);
    port
        ( clock : in  std_logic
        ; data  : out std_logic_vector(width - 1 downto 0)
        ; done  : out std_logic
        );
end entity Lfsr;

architecture Rtl of Lfsr is
    signal shift_register : std_logic_vector(width - 1 downto 0);
    signal lsb            : std_logic;
begin
    process (clock) begin
        if rising_edge (clock) then
            shift_register <= shift_register(width - 2 downto 0) & lsb;
        end if;
    end process;

    lsb  <= shift_register(width - 1) xnor shift_register(width - 2);
    done <= '1' when (unsigned(shift_register) = 0) else '0';
    data <= shift_register;
end architecture Rtl;