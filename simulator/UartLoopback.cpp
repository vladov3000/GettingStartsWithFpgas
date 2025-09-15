/*
 * Tests that every bit received by the UART is transmitted back out at the baud rate.
 *
 * Run the simulation with:
 * ./build.sh --simulate --generic clocks_per_bit 2 modules/UartLoopback.vhdl modules/UartSerialize.vhdl modules/UartDeserialize.vhdl modules/HexDisplay.vhdl modules/SegmentDisplay.vhdl
 * 
 */
#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>

#include "../output/UartLoopback.cpp"

#ifndef CLOCKS_PER_BIT
#warning "Missing clocks_per_bit generic parameter."
#define CLOCKS_PER_BIT 217
#endif

int main() {
    cxxrtl_design::p_UartLoopback top;
    top.p_uart__rx.set(true);

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");
    vcd.add_without_memories(all_debug_items);

    std::ofstream waves("output/waves.vcd");

    value<8> input_byte;
    value<8> output_byte;

    for (int step = 0; step < 1000; step++) {
        top.p_clock.set(true);

        int state = step / CLOCKS_PER_BIT % 10;
        if (state == 0) {
            top.p_uart__rx.set(false);
            input_byte = value<8>((unsigned) rand());
        }
        else if (state < 9) {
            top.p_uart__rx.set(input_byte.bit(state - 1));
        }
        else if (state == 9) {
            top.p_uart__rx.set(true);
        }

        top.step();
        vcd.sample(2 * step);

        top.p_clock.set(false);

        top.step();
        vcd.sample(2 * step + 1);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}
