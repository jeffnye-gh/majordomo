cmake_minimum_required(VERSION 3.10)

project(dromajo_tests)

message(STATUS "Configuring dromajo md_regress target")

include_directories(${PROJECT_SOURCE_DIR}/..)

# Enable CTest
include(CTest)

# Handy parallel processor library
include(ProcessorCount)
ProcessorCount(NUM_CORES)

if (NOT NUM_CORES OR NUM_CORES EQUAL 0)
  set(NUM_CORES 1)
endif()

if (NOT NUM_CORES EQUAL 0)
  set(CTEST_BUILD_FLAGS -j${NUM_CORES})
  set(ctest_test_args "--parallel")
endif()

message(STATUS "Found " ${NUM_CORES} " cores in machine (for ctest)")

add_subdirectory(stf_load_store)

# Add the riscv_isa_test target using its Makefile
add_custom_target(isa_test_suite
  COMMAND ${CMAKE_COMMAND} -E echo "Running isa_test_suite Makefile..."
  COMMAND ${CMAKE_MAKE_PROGRAM} -C ${PROJECT_SOURCE_DIR}/isa_test_suite
  COMMENT "Building isa_test_suite"
)

# Ensure the riscv_isa_test is run when md_regress is run
add_custom_target(md_regress)
add_dependencies(md_regress dromajo isa_test_suite)

add_custom_command(TARGET md_regress POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E echo "Running tests..."
                   COMMAND ${CMAKE_CTEST_COMMAND} ${ctest_test_args})
                   
# Target to be run after changes in tests, e.g. changes to stf_load_store sources
add_custom_target(update_test_files)
add_dependencies(update_test_files stf_load_store_bare stf_load_store_linux)

add_test(NAME stf_load_store_baremetal
  COMMAND ${CMAKE_COMMAND} -E env bash -c "bash scripts/run_baremetal_test.sh 2>&1"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/stf_load_store)

add_test(NAME reset_vector_tests
        COMMAND ${CMAKE_COMMAND} -E env bash -c "bash run_test.sh 2>&1"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/reset_vector)

add_test(NAME directed_tests
        COMMAND ${CMAKE_COMMAND} -E env bash -c "make"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/directed) 
   
add_test(NAME riscv_isa_tests
         COMMAND ${CMAKE_COMMAND} -E env bash -c "bash run_riscv_isa_test_suite.sh 2>&1"
         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/isa_test_suite)

