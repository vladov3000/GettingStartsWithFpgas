library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity StateMachine is
    port ( clock    : in  std_logic
         ; switches : in  std_logic_vector(3 downto 0)
         ; score    : out unsigned(3 downto 0)
         ; leds     : out std_logic_vector(3 downto 0)
         );
end StateMachine;

architecture Rtl of StateMachine is
    type StateType is
        ( start
        , pattern_off
        , pattern_show
        , wait_player
        , increment_score
        , loss
        , win
        );

    type Patterns is array (0 to 10) of std_logic_vector(1 downto 0);

    constant game_limit : integer := 6;
    constant clock_hz   : integer := 25000000; -- 25 MHz

    signal state          : StateType;
    signal released       : std_logic;
    signal pattern_index  : natural range 0 to game_limit;
    signal toggle         : std_logic;
    signal saved_toggle   : std_logic;
    signal pattern        : Patterns;
    signal switch_id      : std_logic_vector(1 downto 0);
    signal lsfr_data      : std_logic_vector(21 downto 0);
    signal saved_switches : std_logic_vector(3 downto 0);
    signal enable_count   : std_logic;
begin
    process (clock) is begin
        if rising_edge(clock) then
            if switches(0) = '1' and switches(1) = '1' then
                state <= start;
            else
                case state is
                    when start =>
                        if switches(0) = '0' and switches(1) = '0' and released = '1' then
                            score         <= to_unsigned(0, score'length);
                            pattern_index <= 0;
                            state         <= pattern_off;
                        end if;

                        pattern(0)  <= lsfr_data(1  downto 0 );
                        pattern(1)  <= lsfr_data(3  downto 2 );
                        pattern(2)  <= lsfr_data(5  downto 4 );
                        pattern(3)  <= lsfr_data(7  downto 6 );
                        pattern(4)  <= lsfr_data(9  downto 8 );
                        pattern(5)  <= lsfr_data(11 downto 10);
                        pattern(6)  <= lsfr_data(13 downto 12);
                        pattern(7)  <= lsfr_data(15 downto 14);
                        pattern(8)  <= lsfr_data(17 downto 16);
                        pattern(9)  <= lsfr_data(19 downto 18);
                        pattern(10) <= lsfr_data(21 downto 20);
                    when pattern_off =>
                        if toggle = '0' and saved_toggle = '1' then
                            state <= pattern_show;
                        end if;
                    when pattern_show =>
                        if toggle = '0' and saved_toggle = '1' then
                            if score = pattern_index then
                                pattern_index <= 0;
                                state         <= wait_player;
                            else
                                pattern_index <= pattern_index + 1;
                                state         <= pattern_off;
                            end if;
                        end if;
                    when wait_player =>
                        if released = '1' then
                            if pattern(pattern_index) = switch_id and pattern_index = score then
                                pattern_index <= 0;
                                state         <= increment_score;
                            elsif pattern(pattern_index) /= switch_id then
                                state <= loss;
                            else
                                pattern_index <= pattern_index + 1;
                            end if;
                        end if;
                    when increment_score =>
                        score <= score + 1;
                        if score = game_limit then
                            state <= win;
                        else
                            state <= pattern_off;
                        end if;
                    when loss   => score <= X"F";
                    when win    => score <= X"A";
                    when others => state <= start;
                end case;
            end if;

            for i in leds'range loop
                leds(i) <= '1' when (state = pattern_show and unsigned(pattern(pattern_index)) = i) else switches(i);
            end loop;

            saved_toggle   <= toggle;
            saved_switches <= switches;
            
            if saved_switches(0) = '1' and switches(0) = '0' then
                released  <= '1';
                switch_id <= "00";
            elsif saved_switches(1) = '1' and switches(1) = '0' then
                released  <= '1';
                switch_id <= "01";
            elsif saved_switches(2) = '1' and switches(2) = '0' then
                released  <= '1';
                switch_id <= "10";
            elsif saved_switches(3) = '1' and switches(3) = '0' then
                released  <= '1';
                switch_id <= "11";
            else
                released  <= '0';
                switch_id <= "00";
            end if;
        end if;
    end process;

    enable_count <= '1' when state = PATTERN_OFF or state = PATTERN_SHOW else '0';

    count_and_toggle : entity work.CountAndToggle
        generic map (count_limit => clock_hz / 4)
        port map
            ( clock  => clock
            , enable => enable_count
            , toggle => toggle
            );

    lfsr : entity work.Lfsr port map
        ( clock => clock
        , data  => lsfr_data
        , done  => open
        );
end architecture Rtl;
