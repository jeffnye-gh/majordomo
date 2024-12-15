
.PHONY: bin-bare-metal-dhrystone \
        bin-gcc-bare-metal-dhrystone \
        bin-llvm-bare-metal-dhrystone

# These come from Vars.mk
GCC_B_EXT  = $(BM_FILE_EXT)
GCC_L_EXT  = $(LNX_FILE_EXT)
LLVM_B_EXT = $(LLVM_BM_FILE_EXT)
LLVM_L_EXT = $(LLVM_LNX_FILE_EXT)

# top level bin directory
BIN    = ./bin

SRC    = src/dhrystone/dhry_1.c src/dhrystone/dhry_2.c src/dhrystone/strcmp.S
BM_SRC = src/dhrystone/memcpy.c src/dhrystone/printf.c src/dhrystone/traps.c \
         cmn/crt.S

GCC_BM_OPT1_OBJ =  obj/dhry_1_gcc_bm_opt1.o \
                   obj/dhry_2_gcc_bm_opt1.o \
                   obj/memcpy_gcc_bm_opt1.o \
                   obj/printf_gcc_bm_opt1.o \
                   obj/strcmp_gcc_bm_opt1.o \
                   obj/traps_gcc_bm_opt1.o  \
                   obj/crt_gcc_bm_opt1.o 

BM_HDR      = src/dhrystone/dhry.h

BM_DEF = -DPREALLOCATE=1 -D__riscv=1 \
         -DMAJORDOMO_DRY_OPT3 \
         -DMAJORDOMO_DRY_NO_MALLOC \
         -DMAJORDOMO_DRY_NO_PRINTF \
         -DMAJORDOMO_DRY_MCYCLE \
         -DDHRY_ITERS=1000

G_WARN = -Wno-builtin-declaration-mismatch \
         -Wno-implicit-function-declaration \
         -Wno-pointer-to-int-cast \
         -Wno-implicit-int

BM_ARCH  = -march=rv64gc_zba_zbb_zbc_zbs -mabi=lp64d -mcmodel=medany
BM_BASIC = -nostdlib -nostartfiles
BM_STD   = -static -std=gnu99
BM_FUNC  = -ffast-math -funsafe-math-optimizations -finline-functions \
           -fno-common \
           -fno-builtin-printf
BM_INC   = -I./inc -I./cmn
LNK_SCR  = -T./linker/linker.ld

# -------------------------------------------------------------------------
DRY_BM_CMN  = $(BM_ARCH) $(BM_BASIC) $(BM_STD) $(BM_FUNC) 

GCC_LTO  = -flto -fno-tree-loop-distribute-patterns

GCC_BM_OPT1  = -O2 -fno-inline $(DRY_BM_CMN)            $(BM_DEF) $(BM_INC)
GCC_BM_OPT2  = -O3             $(DRY_BM_CMN)            $(BM_DEF) $(BM_INC)
GCC_BM_OPT3  = -O3             $(DRY_BM_CMN) $(GCC_LTO) $(BM_DEF) $(BM_INC)
# -------------------------------------------------------------------------
bin-gcc-bare-metal-dhrystone:  $(BIN)/dhrystone_opt1.bare.elf  \
                               $(BIN)/dhrystone_opt2.bare.elf  \
                               $(BIN)/dhrystone_opt3.bare.elf   
# ----------------------------------------------------------------------
# GCC - Bare metal
# ----------------------------------------------------------------------
# GCC BM - OPT1
obj/crt_gcc_bm_opt1.o:  ./cmn/crt.S
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/dhry_1_gcc_bm_opt1.o:  src/dhrystone/dhry_1.c $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/dhry_2_gcc_bm_opt1.o:  src/dhrystone/dhry_2.c $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/memcpy_gcc_bm_opt1.o:  src/dhrystone/memcpy.c $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/printf_gcc_bm_opt1.o:  src/dhrystone/printf.c $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/strcmp_gcc_bm_opt1.o:  src/dhrystone/strcmp.S $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

obj/traps_gcc_bm_opt1.o:  src/dhrystone/traps.c $(BM_HDR)
	@mkdir -p obj
	$(CC) -c $(GCC_BM_OPT1) $(G_WARN) $< -o $@

$(BIN)/dhrystone_opt1.bare.elf: $(GCC_BM_OPT1_OBJ)
	@mkdir -p bin
	$(CC) $(GCC_BM_OPT1) $(LNK_SCR) $(G_WARN) $^ -o $@
# ----------------------------------------------------------------------
# GCC BM - OPT2
$(BIN)/dhrystone_opt2.bare.elf: $(SRC) $(BM_HDR)
	@mkdir -p bin
	$(CC) $(GCC_BM_OPT2) $(LNK_SCR) $(G_WARN) \
           $(SRC) $(BM_SRC) -o $@
# ----------------------------------------------------------------------
# GCC BM - OPT3
$(BIN)/dhrystone_opt3.bare.elf: $(SRC) $(BM_HDR)
	@mkdir -p bin
	$(CC) $(GCC_BM_OPT3) $(LNK_SCR) $(G_WARN) \
           $(SRC) $(BM_SRC) -o $@

help-%:
	@echo $* = $($*)

