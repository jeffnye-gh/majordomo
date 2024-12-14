
# Majordomo - RISC-V Golden Model

NOTE: this is not suitable as a production golden model for RISC-V. See Caveats.

This started as a fork of the Dromajo RISC-V golden model.
The original repo is here: https://github.com/chipsalliance/dromajo.

The fork has been removed.

This source is derived from the Esperanto source which was
in turn derived from Fabrice Bellard's RISCVEMU/TinyEMU.

The original contents of the Esperanto README.md are found in
doc/ESPERANTO_README.md.  Some of the original contents are also duplicated
here.

## Prerequisites

### Cross compilers
You must have cross compilers installed for linux and bare metal. At the time
of writing these links pointed to Ubuntu 22.04, GCC 14 versions of the compilers.

https://buildbot.embecosm.com/job/riscv-embedded-ubuntu2204/29/artifact/riscv-embecosm-embedded-ubuntu2204-20240407.tar.gz

https://buildbot.embecosm.com/job/riscv64-linux-gcc-ubuntu2204/20/artifact/riscv64-embecosm-linux-gcc-ubuntu2204-20240407.tar.gz

These compilers support 32 and 64 bit RISC-V machines but do not always have the requisite naming conventions applied.

Majordomo looks for tool prefixes that begin with riscv64-unknown-elf-\<tool\>

In recent releases of the Embecosm compilers you must create links from the tools labeled with riscv32 to riscv64.

Here is an example script
```
#!/bin/bash

# Iterate over all files starting with "riscv32-unknown-elf-"
for file in riscv32-unknown-elf-*; do
    # Skip if the file is already a symlink
    if [ -L "$file" ]; then
        echo "Skipping symlink: $file"
        continue
    fi

    # Replace "riscv32" with "riscv64" in the file name to create the link name
    link_name="${file/riscv32/riscv64}"

    # Create the symbolic link
    ln -s "$file" "$link_name"
    echo "Created symlink: $link_name -> $file"
done
```

### Environment variables

cd to the top of your install directory 

```
cd majordomo
export MAJORDOMO_TOP="$PWD"
echo $MAJORDOMO_TOP
```

Export RISCV to your cross compiler directory, example:
```
export RISCV=/usr/local/riscv-embecosm-embedded-ubuntu2204-20240407
```

## Caveats

This version has incomplete/limited support for configurations beyond 
but RV64 XLEN=64 FLEN=64.

Majordomo runs a subset of the riscv-isa-tests suite. The subset of tests run by
Majordomo is recorded in tests/isa\_test\_suite/isa\_tests\_list.txt. One test
per line, lines beginning with x are commented out.

As extension support is added tests from the riscv-isa-tests suite are enabled.


## Cloning, build and run regression

NOTE: At present the regression is very limited.

NOTE: the `md_regress` target name

```
git clone --recurse-submodules git@github.com:jeffnye-gh/cpm.dromajo.git
cd cpm.dromajo
mkdir build
cd build
cmake ..
make -j$(nproc) md_regress
```

## Build artifacts
```
TODO: description
```

## Usage

From the build directory - boot linux
```
./majordomo --ctrlc --march=rv64gc ../scripts/md.boot.cfg
```

From the build directory - run an elf file with tracing or with STF creation
```
./majordomo --march=rv64gc ../scripts/bmi_mm.bare.riscv
./majordomo --stf_trace trace.zstf --stf_priv_modes USHM ../scripts/bmi_mm.bare.riscv
```

From the build directory - run one of the  directed tests
```
./majordomo --march=rv64gc_zfa ../tests/directed/bin/zfa/rv64ud-p-fleq_d
```

## STF trace options

Command line options are added to control STF trace generation.

```
    --stf_trace <file> Dump an STF trace to the given file
                  Use .zstf as the file extension for compressed trace
                  output. Use .stf for uncompressed output
    --stf_exit_on_stop_opc Terminate the simulation after 
                  detecting a STOP_TRACE opcode. Using this
                  switch will disable non-contiguous region
                  tracing. The first STOP_TRACE opcode will 
                  terminate the simulator.
    --stf_memrecord_size_in_bits write memory access size in bits
                   instead of bytes
    --stf_trace_register_state include register state in the STF
                   (default false)
    --stf_disable_memory_records Do not add memory records to 
                   STF trace. By default memory records are 
                   always traced.
                   (default false)
    --stf_priv_modes <USHM|USH|US|U> Specify which privilege 
                  modes to include for STF trace generation
    --stf_force_zero_sha Emit 0 for all SHA's in the STF header. This is a 
                  debug option. Also clears the dromajo version placed in
                  the STF header.
```

## Enabling RISC-V extensions
```
TODO: how to enable RV extensions
```

## Running Majordomo with custom start of program memory
```
TODO: usage examples
```

## Testing
```
TODO: usage examples
```
### Test targets

To run regression
```
make -j regress
```

Jeff Nye 2024 - 
