#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>

#include "../output/LedToggle.cpp"

int main() {
    cxxrtl_design::p_LedToggle top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    vcd.add_without_memories(all_debug_items);

    std::ofstream waves("output/waves.vcd");

    // The test randomly pushes and releases the button, and expects that the led is only
    // toggled when the button is released.
    bool led = false;

    for (int step = 0; step < 1000; step++) {
        top.p_clock.set<bool>(false);
        top.step();
        vcd.sample(2 * step);

        bool toggle   = (rand() & 1) == 0;
        bool pushed   = top.p_switch1.get<bool>();
        bool released = toggle && pushed;
        if (toggle) {
            top.p_switch1.set<bool>(!pushed);
        }

        top.p_clock.set<bool>(true);
        top.step();
        vcd.sample(2 * step + 1);

        assert(top.p_led1.get<bool>() == led);
        if (released) {
            led = !led;
        }

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
