/*
 * Simulate random pushes and releases of the button, expecting that the led is only
 * toggled when switch1 is released.
 * 
 * Run the simulation with:
 * ./build.sh --simulate ./modules/LedToggle.vhdl
 * 
 */

#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>

#include "../output/LedToggle.cpp"

using Bit = value<1>;

int main() {
    cxxrtl_design::p_LedToggle top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    Bit expected_led;
    Bit state;
    vcd.add_without_memories(all_debug_items);
    vcd.add("state", state);
    vcd.add("expected_led", expected_led);

    std::ofstream waves("output/waves.vcd");

    for (int step = 0; step < 1000; step++) {
        Bit next_clock        = top.p_clock.bit_not();
        Bit next_switch       = top.p_switch1;
        Bit next_state        = state;
        Bit next_expected_led = expected_led;

        if (!top.p_clock && state && !top.p_switch1) {
            next_switch       = Bit((rand() & 1) == 0);
            next_state        = top.p_switch1;
            next_expected_led = expected_led.bit_not();
        }

        vcd.sample(step);
        top.step();

        top.p_clock   = next_clock;
        top.p_switch1 = next_switch;
        state         = next_state;
        expected_led  = next_expected_led;

        assert(top.p_led1 == expected_led);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
