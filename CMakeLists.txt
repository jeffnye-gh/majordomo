#
# Majordomo, a RISC-V Emulator (based on Fabrice Bellard's RISCVEMU/TinyEMU)
#
# Copyright (c) 2016-2017 Fabrice Bellard
# Copyright (c) 2018,2019,2020 Esperanto Technology
# Copyright (c) 2024 Jeff Nye
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# THIS FILE IS BASED ON RISCVEMU SOURCE CODE WHICH IS DISTRIBUTED UNDER
# THE FOLLOWING LICENSE:
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 20)
project(majordomo)
option(TRACEOS "TRACEOS" OFF)
option(SIMPOINT "SIMPOINT" OFF)
option(GOLDMEM "GOLDMEM" OFF)
option(WARMUP "WARMUP" OFF)

# Set version numbers
set(VERSION_MAJOR 4)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
find_package(Boost REQUIRED COMPONENTS program_options)
include_directories(${Boost_INCLUDE_DIRS})
# -------------------------------------------------------------------------
# Capture GIT SHA in include/majordomo_sha.h
# -------------------------------------------------------------------------
# Verify Git - should never fail
find_package(Git REQUIRED)

# Get current hash
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE MAJORDOMO_GIT_SHA
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# SHA header config file
configure_file(
    "${CMAKE_SOURCE_DIR}/include/majordomo_sha.h.in"
    "${CMAKE_BINARY_DIR}/majordomo_sha.h"
)

# Include the current build directory 
include_directories("${CMAKE_BINARY_DIR}")

# -------------------------------------------------------------------------
# Capture GIT SHA of stf_lib in include/stf_lib_sha.h
# -------------------------------------------------------------------------
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/stf_lib
    OUTPUT_VARIABLE STF_LIB_GIT_SHA
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

configure_file(
    "${CMAKE_SOURCE_DIR}/include/stf_lib_sha.h.in"
    "${CMAKE_BINARY_DIR}/stf_lib_sha.h"
)

# -------------------------------------------------------------------------
# remove -Wno-deprecated-declarations once STF_LIB is patched for c++20
# -------------------------------------------------------------------------
add_compile_options(
        -g
        -Wall
        -Wno-parentheses
        -MMD
        -D_FILE_OFFSET_BITS=64
        -D_LARGEFILE_SOURCE
        -D_GNU_SOURCE
        -D__STDC_FORMAT_MACROS
        -Wno-deprecated-declarations
)

add_compile_options($<$<CONFIG:Release>:-Ofast>)

if (TRACEOS)
    message(STATUS "TRACEOS is on.")
    add_compile_options(
            -DDUMP_UART
            -DDUMP_CLINT
            -DDUMP_PLIC
            -DDUMP_INTERRUPTS
            -DDUMP_ILLEGAL_INSTRUCTIONS
    )
endif ()

if (SIMPOINT)
    add_compile_options(
            -DSIMPOINT_BB
    )
endif ()

if (WARMUP)
  message(STATUS "Checkpoint with WARMUP is on (typically for simpoints, but any checkpoint can use it).")
    add_compile_options( -DLIVECACHE)
endif ()

if (GOLDMEM)
    message(STATUS "GOLDMEM is on.")
    add_compile_options( -DGOLDMEM)
    add_compile_options( -DGOLDMEM_INORDER)  # This is to debug the flow without RTL
    add_library(gold STATIC
            gold/Gold_core.cpp
            gold/Gold_data.cpp
            gold/Gold_notify.cpp
            gold/lrand.cpp
            gold/bridge_inorder.cpp
            external/fmt/format.cc
            external/fmt/os.cc
            )
    include_directories(gold)
endif ()

# libmajordomo_cosim
add_library(majordomo_cosim STATIC
        src/bin_utils.cpp
        src/block_device.cpp
        src/cutils.cpp
        src/majordomo_cosim.cpp
        src/majordomo_main.cpp
        src/majordomo_stf.cpp
        src/majordomo_trace.cpp
        src/dw_apb_uart.cpp
        src/elf64.cpp
        src/fdt.cpp
        src/fs.cpp
        src/fs_disk.cpp
        src/iomem.cpp
        src/interrupts.cpp
        src/json.cpp
        src/machine.cpp
        src/misc.cpp
        src/network.cpp
        src/options.cpp
        src/pci.cpp
        src/riscv_cpu.cpp
        src/riscv_isa.cpp
        src/riscv_machine.cpp
        src/softfp.cpp
        src/term_io.cpp
        src/uart.cpp
        src/virtio.cpp
        src/LiveCache.cpp
        src/zfa.cpp
        )

add_executable(majordomo src/majordomo.cpp)
add_executable(majordomo_cosim_test src/majordomo_cosim_test.cpp)

target_link_libraries(majordomo Boost::program_options)
target_link_libraries(majordomo_cosim_test Boost::program_options)
target_link_libraries(majordomo_cosim Boost::program_options)

if (GOLDMEM)
  target_link_libraries(majordomo majordomo_cosim gold)
  target_link_libraries(majordomo_cosim_test majordomo_cosim gold)
else ()
  target_link_libraries(majordomo majordomo_cosim)
  target_link_libraries(majordomo_cosim_test majordomo_cosim)
endif ()

include_directories(include external ${CMAKE_CURRENT_BINARY_DIR})

# -------------------------------------------------------------------
# Change the name of the copied file if SIMPOINT option is enabled
# -------------------------------------------------------------------
if(SIMPOINT)
    set(MAJORDOMO_NAME simpoint_majordomo)
else()
    set(MAJORDOMO_NAME majordomo)
endif()

set(LOCAL_BIN_DIR ../bin)
add_custom_command(TARGET majordomo POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LOCAL_BIN_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:majordomo>
                                     ${LOCAL_BIN_DIR}/${MAJORDOMO_NAME}
    COMMENT "Copying majordomo to ${LOCAL_BIN_DIR} as ${MAJORDOMO_NAME}")

# -------------------------------------------------------------------
# STF
set(DISABLE_STF_DOXYGEN 1)
set(NO_STF_LTO 1)
set(STF_LIB_BASE ${PROJECT_SOURCE_DIR}/stf_lib)
include(${STF_LIB_BASE}/cmake/stf-config.cmake)

include_directories(${STF_LIB_BASE})
target_link_directories(majordomo PRIVATE ${STF_LIB_BASE}/build/lib)
target_link_libraries(majordomo ${STF_LINK_LIBS})

target_link_directories(majordomo_cosim PRIVATE ${STF_LIB_BASE}/build/lib)
target_link_libraries(majordomo_cosim ${STF_LINK_LIBS})

# Add STF library to the build
add_subdirectory (${STF_LIB_BASE})

# -------------------------------------------------------------------
# TESTS

enable_testing()

# Add tests subdirectory to the build
add_subdirectory (tests)

# -------------------------------------------------------------------
if (${CMAKE_HOST_APPLE})
    include_directories(/usr/local/include /usr/local/include/libelf /opt/homebrew/include /opt/homebrew/include/libelf)
    target_link_libraries(majordomo_cosim -L/usr/local/lib -L/opt/homebrew/lib -lelf)
else ()
    # add librt for Linux
    target_link_libraries(majordomo_cosim rt)
endif ()

install(TARGETS majordomo_cosim DESTINATION .)
