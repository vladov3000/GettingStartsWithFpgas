#!/usr/bin/env bash

set -e

input_path=$1
input=$(basename "${input_path%.vhdl}")

mkdir -p output
ghdl analyze --workdir=output "$input_path"
(cd output && yosys -m ghdl -p "ghdl $input; write_cxxrtl $input.cpp" -Q)

cxxrtl_include="$(yosys-config --datdir)/include/backends/cxxrtl/runtime"
g++ -I "$cxxrtl_include" -I "output" -o "output/$input" "simulator/$input.cpp"
./output/"$input"
