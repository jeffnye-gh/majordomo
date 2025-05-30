// trace_macros.hpp
#ifndef __TRACE_MACROS
#define __TRACE_MACROS

#include <stdint.h>
extern volatile uint64_t tohost;
//
// If the user is including this file in a RISC-V workload, define the
// start/stop trace markers
//
#ifdef __riscv

#ifndef START_TRACE
#define START_TRACE   asm volatile ("xor x0, x0, x0");
#endif

#ifndef STOP_TRACE
#define STOP_TRACE   asm volatile ("xor x0, x1, x1");
#endif

#else //#ifdef __riscv

// JNYE defined here to disable them for x86 linux test builds
#define START_TRACE
#define STOP_TRACE

//
// If the user is including this file in a simulator, identify the
// 32-bit opcodes that represent the start/stop markers
//
#ifndef START_TRACE_OPC
#define START_TRACE_OPC 0x00004033
#endif

#ifndef STOP_TRACE_OPC
#define STOP_TRACE_OPC  0x0010c033
#endif

#endif //ifdef __riscv

#endif //ifndef __TRACE_MACROS
