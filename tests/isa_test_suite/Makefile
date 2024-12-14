RISCV_TESTS_DIR = ../riscv-tests
RISCV_TESTS_INSTALL_DIR = $(shell pwd)/riscv-test-files
RISCV_GCC_OPTS = "-DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 \
-ffast-math -fno-common -fno-builtin-printf -fno-tree-loop-distribute-patterns \
-march=rv64gcv -mabi=lp64d -Wno-implicit-int -Wno-implicit-function-declaration"

NC := $(shell nproc)

# RISCV environment variable must be set
ifndef RISCV
    $(error RISCV environment variable is not set. \
    Please set it to the RISC-V toolchain installation directory. \
    Example: export RISCV=/data/tools/riscv64-unknown-elf)
endif

all: build_riscv_tests

build_riscv_tests:
	@rm -rf $(RISCV_TESTS_INSTALL_DIR)
	@export RISCV_PREFIX=$(RISCV)/bin/riscv64-unknown-elf- && \
	cd $(RISCV_TESTS_DIR) && autoupdate && autoconf && \
	./configure --prefix=$(RISCV_TESTS_INSTALL_DIR) && \
	$(MAKE) isa  && \
	$(MAKE)  benchmarks RISCV_GCC_OPTS=$(RISCV_GCC_OPTS) && \
	$(MAKE)  install
	

clean_install:
	@echo "Cleaning up install..."
	@rm -rf $(RISCV_TESTS_INSTALL_DIR)

clean_all:
	@echo "Cleaning up all..."
	@rm -rf $(RISCV_TESTS_INSTALL_DIR)
	@$(MAKE) -C $(RISCV_TESTS_DIR) clean

.PHONY: all build_riscv_tests clean_install clean_all
