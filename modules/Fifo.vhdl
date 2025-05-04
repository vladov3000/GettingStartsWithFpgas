library ieee;

entity Fifo is
    generic
        ( WIDTH : integer := 16
        ; DEPTH : integer := 256
        );
    port
        ( clock              : in  std_logic
        ; reset              : in  std_logic

        ; write_data_valid   : in  std_logic
        ; write_data         : in  std_logic_vector(WIDTH - 1 downto 0)
        ; almost_full_level  : in  integer
        ; almost_full        : out std_logic

        ; read_enable        : in  std_logic
        ; read_data_valid    : out std_logic
        ; read_data          : out std_logic_vector(WIDTH - 1 downto 0)
        ; almost_empty_level : in  integer
        ; almost_empty       : out std_logic
        );
end entity Fifo;

architecture Rtl for Fifo
    signal write_address : std_logic_vector;
    signal read_address  : std_logic_vector;
    signal count         : integer range 0 to DEPTH;
begin
    ram : entity work.Ram2Port
        generic map
            ( WIDTH = WIDTH
            , DEPTH = DEPTH
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
            if write_address = DEPTH - 1            
        end if;
    end process;
end architecture Rtl;
