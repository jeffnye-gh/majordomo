

# Cosimulation summary

Dromajo is built to have cosimulation against another simulator or RTL. The
goal is to support single core and multicore.



## Build majordomo to cosim against a trace file


To understand the cosimulation API, a trace driven cosimulation is possible.

```
mkdir build_trace
cd build_trace
cmake -DCMAKE_BUILD_TYPE=Debug ../
make -j
```

To create a trace, run any risc-v executable or checkpoint with majordomo as usual
but create a trace

```
./majordomo --maxinsns 10k --trace 0 ../riscv-simple-tests/rv64ua-p-amoxor_d 2>check.trace
```

To read the trace and check that it is correct:

```
./majordomo_cosim_test read check.trace
```

To co-simulate the trace against another instance of majordomo, and disassemble the trace

```
./majordomo_cosim_test  cosim check.trace ../riscv-simple-tests/rv64ua-p-amoxor_d
```

If you have spike installed, you could:

```
./majordomo_cosim_test  cosim check.trace ../riscv-simple-tests/rv64ua-p-amoxor_d | spike-dasm
```

