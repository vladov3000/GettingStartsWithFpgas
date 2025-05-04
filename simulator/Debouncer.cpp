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

using cxxrtl::value;

int main() {
    cxxrtl_design::p_Debouncer top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    value<1> expected_led(false);

    vcd.add_without_memories(all_debug_items);
    vcd.add("expected_led", cxxrtl::debug_item(expected_led));

    std::ofstream waves("output/waves.vcd");

    int max_count = limit - 1;

    bool debounced = false;
    int  count     = 0;
    bool state     = false;

    top.p_switch1.set(true);

    for (int step = 0; step < 1000; step++) {
        bool switch_bool = top.p_switch1.get<bool>();

        bool     next_switch       = switch_bool;
        value<1> next_expected_led = expected_led;
        bool     next_debounced    = debounced;
        int      next_count        = count;
        bool     next_state        = debounced;

        if (switch_bool != debounced && count < max_count) {
            next_count = count + 1;
        } else if (count == max_count) {
            next_debounced = switch_bool;
            next_count     = 0;
            next_switch    = !switch_bool; // Turn switch off/on after we hold it for long enough.
        } else {
            next_count = 0;
        }

        // Introduce jitter with a probablity of 2 ^ (-1/limit), such that 1/2 holds succeeds.
        if (rand() & ((1 << limit) - 1) == 0) {
            next_switch = !switch_bool;
        }

        if (!debounced && state) {
            next_expected_led = expected_led.bit_not();
        }

        assert(expected_led == top.p_led1);

        // Toggle clock.
        for (int i = 0; i < 2; i++) {
            top.p_clock.set(i == 0);
            top.step();
            vcd.sample(2 * step + i);
        }

        top.p_switch1.set(next_switch);
        expected_led = next_expected_led;
        debounced    = next_debounced;
        count        = next_count;
        state        = next_state;

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
