#!/usr/bin/env bash

# -e Exit on any non-zero exit code.
# -x Show commands before they are executed.
set -ex

state=initial

for argument in "$@"; do
    case "$state" in
        initial)
            case "$argument" in
                --program)
                    program=true
                    ;;
                --simulate)
                    simulate=true
                    ;;
                --generic)
                    state=generic_key
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
            ;;
        generic_key)
            generic_key=$argument
            state=generic_value
            ;;
        generic_value)
            generic_value=$argument
            generics_ghdl+=("-g$generic_key=$generic_value")
            generics_gcc+=("-D$generic_key=$generic_value")
            state=initial
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
ghdl --std=08 ${generics_ghdl[*]} ${dependency_paths[*]} $input_path -e $input;
write_cxxrtl output/$input.cpp
END
    cxxrtl_include="$(yosys-config --datdir)/include/backends/cxxrtl/runtime"
    g++ -std=c++20 -I "$cxxrtl_include" -I "output" -o "output/$input" "${generics_gcc[@]}" "simulator/$input.cpp"
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
