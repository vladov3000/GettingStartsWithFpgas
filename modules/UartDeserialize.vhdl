library ieee;

use ieee.std_logic_1164.all;

entity UartDeserialize is 
    generic
        ( clocks_per_bit : integer := 217
        );
    port
        ( clock      : in std_logic
        ; uart_rx    : in std_logic
        ; byte_valid : out std_logic
        ; byte       : out std_logic_vector(7 downto 0)
        );
end entity UartDeserialize;

architecture Rtl of UartDeserialize is
    type StateType is (idle, start_bit, data_bit, stop_bit);

    signal state     : StateType;
    signal rx_buffer : std_logic;
    signal rx_bit    : std_logic;
    signal count     : natural range 0 to clocks_per_bit;
    signal index     : natural range 0 to byte'length - 1;
begin
    process (clock) is begin
        if rising_edge(clock) then
            case state is
                when idle =>
                    byte_valid <= '0';
                    count      <= 0;
                    if rx_bit = '0' then
                        state <= start_bit;
                    end if;

                when start_bit =>
                    if count = clocks_per_bit / 2 then
                        count <= 0;
                        index <= 0;
                        state <= data_bit when rx_bit = '0' else idle;
                    else
                        count <= count + 1;
                    end if;

                when data_bit =>
                    if count = clocks_per_bit then
                        count       <= 0;
                        byte(index) <= rx_bit;
                        index       <= index + 1;

                        if index = byte'length - 1 then
                            state <= stop_bit;
                        end if;
                    else
                        count <= count + 1;
                    end if;

                when stop_bit =>
                    if count = clocks_per_bit then
                        byte_valid <= '1';
                        state      <= idle;
                    else
                        count <= count + 1;
                    end if;

            end case;

            rx_buffer <= uart_rx;
            rx_bit    <= rx_buffer;
        end if;
    end process;
end architecture Rtl;
