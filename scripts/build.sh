#!/usr/bin/env sh

set -e

for argument in "$@"; do
    case "$argument" in
        --program)
            program=true
            ;;
        *)
            input_path=$argument
            input=$(basename "${input_path%.vhdl}")
            ;;
    esac
done

frequency=25 # MHz

mkdir -p output
ghdl analyze --workdir=output "$input_path"
(cd output && yosys -m ghdl -p "ghdl $input; synth_ice40 -json $input.json" -Q)
nextpnr-ice40 --hx1k --package vq100 --pcf nandland_go_board.pcf --asc "output/$input.asc" --json output/"$input.json" --freq "$frequency"
icetime -d hx1k -P vq100 -p nandland_go_board.pcf -r "output/$input.rpt" -t "output/$input.asc" -c "$frequency"
icepack "output/$input.asc" output/"$input.bin"

if [ -n "$program" ]; then
    iceprog "output/$input.bin"
fi
