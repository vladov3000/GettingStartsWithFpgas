library ieee;

use ieee.std_logic_1164.all;

entity UartSerialize is 
    generic
        ( clocks_per_bit : integer := 217
        );
    port
        ( clock      : in  std_logic
        ; byte_valid : in  std_logic
        ; input_byte : in  std_logic_vector(7 downto 0)
        ; active     : out std_logic
        ; uart_tx    : out std_logic
        ; done       : out std_logic
        );
end entity UartSerialize;

architecture Rtl of UartSerialize is
    type StateType is (idle, start_bit, data_bit, stop_bit);

    signal state : StateType;
    signal byte  : std_logic_vector(7 downto 0);
    signal count : natural range 0 to clocks_per_bit;
    signal index : natural range 0 to byte'high;
begin
    process (clock) begin
        if rising_edge(clock) then
            case state is
                when idle =>
                    uart_tx <= '1';
                    done    <= '0';
                    count   <= 0;
                    if byte_valid then
                        byte  <= input_byte;
                        state <= start_bit;
                    end if;                        

                when start_bit =>
                    uart_tx <= '0';
                    if count = clocks_per_bit then
                        count <= 0;
                        index <= 0;
                        state <= data_bit;
                    else
                        count <= count + 1;
                    end if;

                when data_bit =>
                    uart_tx <= byte(index);                    
                    if count = clocks_per_bit then
                        count <= 0;
                        if index = byte'high then
                            count <= 0;
                            state <= stop_bit;
                        else
                            index <= index + 1;
                        end if;
                    else
                        count <= count + 1;
                    end if;

                when stop_bit =>
                    uart_tx <= '1';
                    if count = clocks_per_bit then
                        done  <= '1';
                        state <= idle;
                    else
                        count <= count + 1;
                    end if;
            end case;
        end if;
    end process;

    active <= '1' when state = idle else '0';
end architecture Rtl;
