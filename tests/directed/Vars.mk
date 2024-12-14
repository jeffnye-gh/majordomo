# --------------------------------------------------------------------
RVTST_INC=-I./inc -I../riscv-tests/env/p -I../riscv-tests/isa/macros/scalar
RVTST_LNK=-T../riscv-tests/env/p/link.ld
# --------------------------------------------------------------------
# Common settings
# --------------------------------------------------------------------
OBJD_OPTS=--disassemble-all --disassemble-zeroes --section=.text --section=.text.startup \
               --section=.text.init --section=.data -Mnumeric,no-aliases
# --------------------------------------------------------------------

DROM=../../bin/majordomo
COMMON_TEST_FILES=$(MAJORDOMO_TOP)/tests/common_test_files
DROM_OPTS=--ctrlc --trace 0 --march=rv64g_zba_zbb_zbc_zbs_xandes_zfa

# --------------------------------------------------------------------
RISCV_CC_ROOT=$(RISCV)

RISCV_CC=$(RISCV_CC_ROOT)/bin/riscv64-unknown-elf-gcc
RISCV_OBJD=$(RISCV_CC_ROOT)/bin/riscv64-unknown-elf-objdump

BASE_CC_OPTS=  \
 -march=rv64imacdf_zicond_zba_zbb_zbc_zbs_zfa_zfh -mabi=lp64d -mcmodel=medany \
 -nostdlib -nostartfiles -ffast-math -funsafe-math-optimizations \
 -finline-functions -fno-common -fno-builtin-printf \
 -fno-tree-loop-distribute-patterns \
  -DPREALLOCATE=1 -D__riscv=1  -static -std=gnu99

RISCV_CC_OPTS= -O3 -flto $(BASE_CC_OPTS) $(RVTST_INC) $(RVTST_LNK)
RISCV_OBJD_OPTS=$(OBJD_OPTS)
RISCV_SIM=$(DROM)
RISCV_SIM_OPTS=$(DROM_OPTS)

# --------------------------------------------------------------------
DECODER_CC_OPTS= -O3 -flto $(BASE_CC_OPTS) $(RVTST_INC) 
DECODER_LNK=-T$(COMMON_TEST_FILES)/linker/common_proposed.ld
