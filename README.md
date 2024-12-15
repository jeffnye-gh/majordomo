# Majordomo - RISC-V Golden Model

NOTE: this is not suitable as a production golden model for RISC-V. See Caveats.

Majordomo started as a fork of the Dromajo RISC-V golden model. The fork has been removed. See Credits below.

## Prerequisites

A cross compiler is required to run the regression and use the examples. Two environment variables must be set to use build environment.

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

The RISCV and MAJORDOMO_TOP environment variables must be set.

cd to the top of your majordomo install directory 

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


## Clone, build and run regression

NOTE: At present the regression is very limited.

NOTE: the `md_regress` target name

```
git clone --recurse-submodules https://github.com/jeffnye-gh/majordomo.git
```

## Build and test
Set the RISCV env var per your installation. Example shown.

```
cd majordomo
export MAJORDOMO_TOP="$PWD"
export RISCV=/usr/local/riscv-embecosm-embedded-ubuntu2204-20240407
mkdir build
cd build
cmake ..
make -j$(nproc) md_regress
```

### Regression output
Regression results will look similar to this, execution times are dependent on 
host compiler optimizations. 

riscv\_isa\_tests can take as long a minute or more to run. 

When built and run under the sparta miniconda environment this has been
seen to reduce runtime to <10 secs.

See the minconda/sparta environment instructions here:
https://github.com/sparcians/map

```
Running tests...
Test project /home/jeff/Development/jeffnye-gh/tmp/majordomo/build/tests
    Start 1: stf_load_store_baremetal
1/4 Test #1: stf_load_store_baremetal .........   Passed   ??.?? sec
    Start 2: reset_vector_tests
2/4 Test #2: reset_vector_tests ...............   Passed   ??.?? sec
    Start 3: directed_tests
3/4 Test #3: directed_tests ...................   Passed   ??.?? sec
    Start 4: riscv_isa_tests
4/4 Test #4: riscv_isa_tests ..................   Passed   ??.?? sec

100% tests passed, 0 tests failed out of 4

```

## Usage

### Basic command line usage
From the build directory - boot linux
```
./majordomo --ctrlc --march=rv64gc ../scripts/md.boot.cfg
```

From the build directory - run an elf file with tracing or with STF creation
```
./majordomo --ctrlc --march=rv64gc --stf_trace trace.zstf --stf_priv_modes USHM ../scripts/main.elf
```

From the build directory - run one of the  directed tests
```
./majordomo --ctrlc --march=rv64gc_zfa ../tests/directed/bin/zfa/rv64ud-p-fleq_d
```

### How to boot linux

Build majordomo as usual. From that build directory executing this command will boot a pre-build linux image.

```
<cd build directory>
./majordomo --ctrlc --march=rv64gc ../linux/md.boot.cfg
```

The user is root, the password is root

### How to create an STF trace from a prebuilt elf

Build majordomo as usual. From that build directory executing this command will create an STF trace of the rvt_mm.bare.elf. (matrix multiply)

```
<cd build directory>
./majordomo --march=rv64gc --stf_trace trace.zstf --stf_priv_modes USHM ../examples/rvt_mm.bare.elf
```
The trace file will be trace.zstf

# Examples

The examples directory contains examples of how to build, run and trace baremetal applications. There is a quick sort example derived from riscv-tests/benchmarks. 

There are also 3 builds of the dhrystone benchmark. These builds conform to the 3 accepted optimization levels used for compiling dhrystone.

The examples directory includes boot strap source and other ancillary files for creating bare metal applications that will run on majordomo. See the Makefile and the dhrystone make file dhry.mk.


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

## Credits & License

This work extends the original Dromajo model provided by Esperanto and extended by Condor Computing. The Esperanto/Condor work was in turn derived from 
RISCVEMU/TinyEMU.

The original TinyEMU source was released under the MIT license.

The Dromajo source was release under the Apache 2.0 license.
The Condor modifications were also released under the Apache 2.0 license.

Files that have been modified for Majordomo retain the original author information and license.  Majordomo carries forward the Apache 2.0 license.  New files are (c) Jeff Nye.

The Dromajo URL is: https://github.com/chipsalliance/dromajo

The TinyEMU URL is: https://bellard.org/tinyemu

There are various URL for RISCVEMU, this is one: https://github.com/sysprog21/riscv-emu

The original contents of the Esperanto README.md are found in
doc/ESPERANTO_README.md.  

