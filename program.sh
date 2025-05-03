#!/usr/bin/env sh

set -e

if [ $# -ne 1 ]; then
    echo "Expected exactly one argument, the input file."
    exit 1
fi

export NAME="${1%.vhdl}"

mkdir -p output
ghdl analyze --workdir=output "$NAME.vhdl"
(cd output && yosys -m ghdl -p "ghdl $NAME; synth_ice40 -json $NAME.json" -Q)
nextpnr-ice40 --hx1k --package vq100 --pcf nandland_go_board.pcf --asc output/"$NAME.asc" --json output/"$NAME.json"
icepack output/"$NAME.asc" output/"$NAME.bin"
iceprog output/"$NAME.bin"
