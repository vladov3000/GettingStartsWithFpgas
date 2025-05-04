#!/usr/bin/env bash

set -e

for argument in "$@"; do
    case "$argument" in
        --program)
            program=true
            ;;
        --simulate)
            simulate=true
            ;;
        *)
            if [ -z "$input_path" ]; then
                input_path=$argument
                input=$(basename "${input_path%.vhdl}")
            else
                dependency_paths+=("$argument")
                dependencies+=("$(basename "${argument%.vhdl}")")
            fi
            ;;
    esac
done

frequency=25 # MHz

# -m Loads the ghdl module, so we can use the vhdl frontend.
# -Q Hides the license notice printed at the start.
yosys_flags=(-m ghdl -Q)

mkdir -p output

if [ -n "$simulate" ]; then
    yosys "${yosys_flags[@]}" <<END
ghdl ${dependency_paths[*]} $input_path -e $input;
write_cxxrtl output/$input.cpp
END
    cxxrtl_include="$(yosys-config --datdir)/include/backends/cxxrtl/runtime"
    g++ -I "$cxxrtl_include" -I "output" -o "output/$input" "simulator/$input.cpp"
    ./output/"$input"
else
    yosys "${yosys_flags[@]}" <<END
ghdl ${dependency_paths[*]} $input_path -e $input;
synth_ice40 -json output/$input.json;
write_json -noscopeinfo output/$input.json;
END
    nextpnr-ice40 --hx1k --package vq100 --pcf nandland_go_board.pcf --asc "output/$input.asc" --json output/"$input.json" --freq "$frequency"
    icetime -d hx1k -P vq100 -p nandland_go_board.pcf -r "output/$input.rpt" -t "output/$input.asc" -c "$frequency"
    icepack "output/$input.asc" output/"$input.bin"

    if [ -n "$program" ]; then
        iceprog "output/$input.bin"
    fi
fi
