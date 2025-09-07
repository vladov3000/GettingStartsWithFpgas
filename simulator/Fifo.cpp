/*
 * Simulate filling and emptying a FIFO.
 *
 * Run the simulation with:
 * ./build.sh --generic width 16 --generic depth 256 --simulate ./modules/Fifo.vhdl ./modules/Ram2Port.vhdl
 * 
 */

#ifndef WIDTH
#warning "Missing width generic parameter."
#define WIDTH 16
#endif

#ifndef DEPTH
#warning "Missing depth generic parameter."
#define DEPTH 256
#endif

#include <cxxrtl/cxxrtl.h>
#include <cxxrtl/cxxrtl_vcd.h>
#include <fstream>
#include <queue>

#include "../output/Fifo.cpp"

using Bit  = value<1>;
using Word = value<WIDTH>;

template<size_t Bits>
static value<Bits> make_random() {
    unsigned bound = 1 << Bits;
    return value<Bits>(rand() % bound);
}

int main() {
    cxxrtl_design::p_Fifo top;

    cxxrtl::debug_items all_debug_items;
    top.debug_info(&all_debug_items, nullptr, "");

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");
    vcd.add_without_memories(all_debug_items);

    std::ofstream waves("output/waves.vcd");

    std::deque<Word> in_flight;

    for (uint64_t step = 0; step < 1000; step++) {
        top.p_clock.set(true);
        top.p_reset.set(step > 0);
        top.p_write__data__valid.set(in_flight.size() < DEPTH && (rand() & 1));
        top.p_write__data = make_random<WIDTH>();
        top.p_read__enable.set(!in_flight.empty() && (rand() & 1));

        top.step();
        vcd.sample(2 * step);

        top.p_clock.set(false);

        top.step();
        vcd.sample(2 * step + 1);

        if (step > 0) {
            if (top.p_read__data__valid) {
                assert(!in_flight.empty());
                assert(in_flight.front() == top.p_read__data);
                in_flight.pop_front();
            }
            if (top.p_write__data__valid) {
                in_flight.push_back(top.p_write__data);
            }
        }

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}