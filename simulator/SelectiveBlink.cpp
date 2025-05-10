/*
 * Ensures that the LSFR really does cause a blink every 2 ^ width seconds.
 *
 * Run the simulation with:
 * ./build.sh --generic lsfr_width 3 --simulate ./modules/SelectiveBlink.vhdl modules/Lfsr.vhdl modules/Demux.vhdl
 * 
 */
#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>
#include <format>

#include "../output/SelectiveBlink.cpp"

#ifndef lsfr_width
#warning "Missing lsfr_width generic parameter."
#define lsfr_width 22
#endif

using Bit   = value<1>;
using Count = value<lsfr_width>;

int main() {
    cxxrtl_design::p_SelectiveBlink top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    Count count;
    Bit   toggle;
    Bit   expected_leds[4] = {};
    vcd.add_without_memories(all_debug_items);
    vcd.add("count", count);
    vcd.add("test_toggle", toggle);
    for (int i = 0; i < 4; i++) {
        std::string name = std::format("expected_led{}", i + 1);
        vcd.add(name, cxxrtl::debug_item(expected_leds[i]));
    }

    std::ofstream waves("output/waves.vcd");

    // It can never reach the all bit set state, because we use xor as our linear
    // function. Hence, the -2.
    Count max_count = Count((1u << lsfr_width) - 2);

    for (int step = 0; step < 1000; step++) {
        int select = rand() & 0b1;
        top.p_switch1.set((select & 1) == 1);
        top.p_switch2.set((select & 2) == 1);

        Bit   next_clock  = top.p_clock.bit_not();
        Count next_count  = count;
        Bit   next_toggle = toggle;

        if (!next_clock) {
            if (count == max_count) {
                next_count = Count(0u);
            } else {
                next_count = count.add(Count(1u));
            }

            if (count.is_zero()) {
                next_toggle = toggle.bit_not();
            }
        }

        vcd.sample(step);
        top.step();

        top.p_clock = next_clock;
        count       = next_count;
        toggle      = next_toggle;

        for (int i = 0; i < 4; i++) {
            expected_leds[i] = Bit(i == select && toggle);
        }

        if (top.p_clock) {
            assert(top.p_led1 == expected_leds[0]);
            assert(top.p_led2 == expected_leds[1]);
            assert(top.p_led3 == expected_leds[2]);
            assert(top.p_led4 == expected_leds[3]);
        }

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
