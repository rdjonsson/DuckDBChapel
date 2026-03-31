# DuckDBChapel build system
# Usage: just [recipe]
#
# Requires: chpl (Chapel compiler), libduckdb (available on PATH/LD_LIBRARY_PATH)

src_dir   := "src"
ex_dir    := "example"
out_dir   := "target"
lib_out   := out_dir / "lib"
ex_out    := out_dir / "example"

main_src  := src_dir / "DuckDBChapel.chpl"
examples  := "duckdbExample columnExample"

# Chapel compiler flags
# -M adds the src directory so submodules (DuckDBChapel/) are found
chpl_flags := "--fast -M " + src_dir

# Default: build library and all examples
default: lib examples

# Build the library module (type-checks + produces a compiled object/binary)
lib:
    mkdir -p {{lib_out}}
    chpl {{chpl_flags}} {{main_src}} -o {{lib_out}}/DuckDBChapel
    @echo "Library built -> {{lib_out}}/DuckDBChapel"

# Build all example programs
examples: _ex_dir duckdbExample columnExample

_ex_dir:
    mkdir -p {{ex_out}}

# Build a single example: just example duckdbExample
example name:
    mkdir -p {{ex_out}}
    chpl {{chpl_flags}} {{ex_dir}}/{{name}}.chpl -o {{ex_out}}/{{name}}
    @echo "Example built -> {{ex_out}}/{{name}}"

# Individual example targets (called by `examples`)
duckdbExample:
    chpl {{chpl_flags}} {{ex_dir}}/duckdbExample.chpl -o {{ex_out}}/duckdbExample
    @echo "Example built -> {{ex_out}}/duckdbExample"

columnExample:
    chpl {{chpl_flags}} {{ex_dir}}/columnExample.chpl -o {{ex_out}}/columnExample
    @echo "Example built -> {{ex_out}}/columnExample"

# Build in debug mode (no optimisations, bounds-checking on)
debug:
    mkdir -p {{lib_out}} {{ex_out}}
    chpl -M {{src_dir}} {{main_src}} -o {{lib_out}}/DuckDBChapel_debug
    for ex in {{examples}}; do \
        chpl -M {{src_dir}} {{ex_dir}}/$ex.chpl -o {{ex_out}}/${ex}_debug; \
    done
    @echo "Debug builds -> {{lib_out}} and {{ex_out}}"

# Run an example: just run duckdbExample
run name: (example name)
    {{ex_out}}/{{name}}

# Remove all build artifacts
clean:
    rm -rf {{out_dir}}
    @echo "Cleaned {{out_dir}}"

# Show help
help:
    @just --list
