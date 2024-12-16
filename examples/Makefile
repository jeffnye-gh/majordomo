.PHONY: default all sanity sim_pmp
# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------
CC=$(RISCV)/bin/riscv64-unknown-elf-gcc
OBJD=$(RISCV)/bin/riscv64-unknown-elf-objdump
MJD=../build/majordomo
# ---------------------------------------------------------------------------
# Shared source
# ---------------------------------------------------------------------------
CMN_SRC=cmn/crt.S cmn/syscalls.c
# ---------------------------------------------------------------------------
# CC flags
# ---------------------------------------------------------------------------
STD = -O3 -nostdlib -nostartfiles -static -std=gnu99
ARCH=-march=rv64gc_zba_zbb_zbc_zbs -mabi=lp64d -mcmodel=medany
INC = -I./cmn -I./inc
DEF = -D__riscv -DPREALLOCATE=1 \
      -Dzba_ENABLED=1 -Dzbb_ENABLED=1 -Dzbc_ENABLED=1 -Dzbs_ENABLED=1
FLAGS=-ffast-math -funsafe-math-optimizations -finline-functions -fno-common \
      -fno-builtin-printf -flto -fno-tree-loop-distribute-patterns 
LIBS=-lm -lgcc
LNK=-Tlinker/linker.ld

CFLAGS=-O3 $(STD) $(ARCH) $(INC) $(DEF) $(FLAGS) $(LNK)
# ---------------------------------------------------------------------------
# objdump flags
# ---------------------------------------------------------------------------
OFLAGS=--disassemble-all --disassemble-zeroes --section=.text \
         --section=.text.startup --section=.text.init  --section=.data \
         -Mnumeric,no-aliases
# ---------------------------------------------------------------------------
# majordomo flags
# ---------------------------------------------------------------------------
MFLAGS = --ctrlc --stf_priv_modes USHM

default: all
# ---------------------------------------------------------------------------
# The dhry.mk makefile conforms to the 3 accepted optimization levels
# https://www.sifive.com/blog/dhrystone-performance-tuning-on-the-freedom-platform
# ---------------------------------------------------------------------------
include dhry.mk
# ---------------------------------------------------------------------------
all: 
	$(MAKE) ./bin/rvt_qsort.bare.elf
	$(MAKE) ./bin/dhrystone_opt1.bare.elf
	$(MAKE) ./bin/dhrystone_opt2.bare.elf
	$(MAKE) ./bin/dhrystone_opt3.bare.elf
	$(MAKE) sim E=rvt_qsort.bare T=rvt_qsort.bare
	$(MAKE) sim E=dhrystone_opt1.bare T=dhrystone_opt1.bare
	$(MAKE) sim E=dhrystone_opt2.bare T=dhrystone_opt2.bare
	$(MAKE) sim E=dhrystone_opt3.bare T=dhrystone_opt3.bare

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
./bin/rvt_qsort.bare.elf:
	$(CC) $(CFLAGS) $(CMN_SRC) -I./src/qsort ./src/qsort/*.c -o $@ $(LIBS)

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
sim:
	@echo "executing $(T)"
	@$(MJD) $(MFLAGS) --stf_trace ./traces/$(T).zstf ./bin/$(E).elf
	
clean:
	-rm -rf bin/* obj/* traces/*
