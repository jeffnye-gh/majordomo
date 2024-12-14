# This scripts helps debug - delete when done
MARCH="-march=rv64imacdf_zicond_zba_zbb_zbc_zbs_zfa_zfh -mabi=lp64d  -mcmodel=medany"

$RISCV/bin/riscv64-unknown-elf-gcc -O3 -flto $MARCH -nostdlib -nostartfiles -ffast-math -funsafe-math-optimizations -finline-functions -fno-common -fno-builtin-printf -fno-tree-loop-distribute-patterns -DPREALLOCATE=1 -D__riscv=1  -static -std=gnu99 -I./inc -I../riscv-tests/env/p -I../riscv-tests/isa/macros/scalar \
  -T$MAJORDOMO_TOP/tests/common_test_files/common_proposed.ld \
  -I./src/decoder src/decoder/*.c src/decoder/*.S \
  -o bin/decoder/decoder.riscv -lm -lgcc

$RISCV/bin/riscv64-unknown-elf-objdump \
  --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init \
  --section=.data -Mnumeric,no-aliases \
  ./bin/decoder/decoder.riscv > ./logs/decoder/decoder.riscv.dump

$MAJORDOMO_TOP/bin/cpm_dromajo --ctrlc --trace 0 \
  --march=rv64g_zba_zbb_zbc_zbs_xandes_zfa \
  ./bin/decoder/decoder.riscv 
