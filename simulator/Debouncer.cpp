/*
 * Simulate pushes and releases of the button, expecting that the led is only
 * toggled when switch1 is held and released after `limit` clock cycles.
 * 
 * Run the simulation with:
 * ./build.sh --generic limit 5 --simulate ./modules/Debouncer.vhdl ./modules/DebounceFilter.vhdl ./modules/LedToggle.vhdl
 * 
 */

#ifndef limit
#warning "Missing limit generic parameter."
#define limit 5
#endif

#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>

#include "../output/Debouncer.cpp"

using Bit = value<1>;

int main() {
    cxxrtl_design::p_Debouncer top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    Bit expected_led;
    Bit debounced;
    Bit state;
    vcd.add_without_memories(all_debug_items);
    vcd.add("expected_led", expected_led);
    vcd.add("test_debounced", debounced);
    vcd.add("test_state", state);

    std::ofstream waves("output/waves.vcd");

    int max_count = limit - 1;
    int count     = 0;

    top.p_switch1.set(true);

    for (int step = 0; step < 1000; step++) {
        Bit next_clock        = top.p_clock.bit_not();
        Bit next_switch       = top.p_switch1;
        int next_count        = count;
        Bit next_debounced    = debounced;
        Bit next_state        = state;
        Bit next_expected_led = expected_led;

        if (!top.p_clock) {
            if (top.p_switch1 != debounced && count < max_count) {
                next_count = count + 1;
            } else if (count == max_count) {
                next_count     = 0;
                next_debounced = top.p_switch1;
            } else {
                next_count = 0;
            }

            // Introduce jitter with a probablity of 2 ^ (-1/limit), such that 1/2 holds succeeds.
            if ((rand() & ((1 << limit) - 1)) == 0) {
                next_switch = top.p_switch1.bit_not();
            }

            if (top.p_switch1 == debounced) {
                next_switch = top.p_switch1.bit_not();
            }

            next_state = debounced;

            if (!debounced && state) {
                next_expected_led = expected_led.bit_not();
            }
        }

        vcd.sample(step);
        top.step();

        top.p_clock   = next_clock;
        top.p_switch1 = next_switch;
        count         = next_count;
        debounced     = next_debounced;
        state         = next_state;
        expected_led  = next_expected_led;

        assert(top.p_led1 == expected_led);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
