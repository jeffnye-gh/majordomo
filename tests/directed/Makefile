.PHONY: default decoder cc_decoder sim_decoder run_test cc_test sim_test \
        zfa zicond

include Vars.mk

ifeq ($(VERBOSE),1)
    Q :=
else
    Q := @
    MAKEFLAGS += -s  # Enable silent mode
endif

default: zicond decoder
#zfa work in progress

decoder: cc_decoder sim_decoder

# -----------------------------------------------------------------------
# zfa work in progress - these are the intended tests
# -----------------------------------------------------------------------
zfa_tests = fli_h fli_s fli_d

#zfa_tests = fleq_h fleq_s fleq_d \
#            fltq_h fltq_s fltq_d \
#            fmaxm_h fmaxm_s fmaxm_d \
#            fminm_h fminm_s fminm_d \
#            fround_h fround_s fround_d \
#            froundnx_h froundnx_s froundnx_d \
#            fmvh_x_d \
#            fcvtmod_w_d \

zfa:
	-mkdir -p bin/zfa logs/zfa
	$(foreach test,$(zfa_tests),$(MAKE) run_test X=rv64ud-p E=zfa T=$(test);)
# -------------------------------------------------------------------------
zicond:	
	mkdir -p bin/zicond logs/zicond
	$(MAKE) run_test X=rv64ui-p E=zicond T=czero_eqz
	$(MAKE) run_test X=rv64ui-p E=zicond T=czero_nez

# -------------------------------------------------------------------------
cc_decoder:
	$(Q)mkdir -p bin/decoder logs/decoder
	$(RISCV_CC) $(DECODER_CC_OPTS) $(DECODER_LNK) \
  -I./src/decoder src/decoder/*.c src/decoder/*.S \
  -o bin/decoder/decoder.riscv -lm -lgcc
	$(Q)$(RISCV_OBJD) $(RISCV_OBJD_OPTS) \
	  ./bin/decoder/decoder.riscv > ./logs/decoder/decoder.riscv.dump

sim_decoder:
	$(Q)$(RISCV_SIM) $(RISCV_SIM_OPTS) \
	  ./bin/decoder/decoder.riscv > ./logs/decoder/decoder.log 2>&1 && \
	echo "Running decoder.riscv ...pass" || echo "Running decoder.riscv ...fail"

# -------------------------------------------------------------------------
run_test:
	$(MAKE) cc_test  X=$(X) EXT=$(E) TST=$(T)
	$(MAKE) sim_test X=$(X) EXT=$(E) TST=$(T)

cc_test:	
	$(Q)$(RISCV_CC) $(RISCV_CC_OPTS) -DXLEN=$(X) \
	  ./src/$(EXT)/$(TST).S -o ./bin/$(EXT)/$(X)-$(TST)
	$(Q)$(RISCV_OBJD) $(RISCV_OBJD_OPTS) \
	  ./bin/$(EXT)/$(X)-$(TST) > ./logs/$(EXT)/$(X)-$(TST).dump

sim_test:
	$(Q)$(RISCV_SIM) $(RISCV_SIM_OPTS) \
	  ./bin/$(EXT)/$(X)-$(TST) > ./logs/$(EXT)/$(X)-$(TST).log 2>&1 && \
	echo "Running $(X)-$(TST) ...pass" || echo "Running $(X)-$(TST) ...fail"

# -------------------------------------------------------------------------
clean:
	-rm -rf bin/* logs/*

