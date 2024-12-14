#!/bin/bash

majordomo_root=$(readlink -f $(dirname $0)/..)

echo "using majordomo_root:"$majordomo_root

pushd .
mkdir -p build_regression
cd build_regression

############################## DEBUG BUILD
pushd .
mkdir -p debug
cd debug
cmake -DCMAKE_BUILD_TYPE=Debug $majordomo_root

make -j
if [ $? -ne 0 ]; then
  echo "FIXME: debug build failed"
  exit 1
fi

make majordomo_cosim_test
if [ $? -ne 0 ]; then
  echo "FIXME: debug majordomo_cosim_test build failed"
  exit 1
fi

popd

############################## RELEASE BUILD
pushd .
mkdir -p release
cd release
cmake $majordomo_root

make -j
if [ $? -ne 0 ]; then
  echo "FIXME: release build failed"
  exit 1
fi

make majordomo_cosim_test
if [ $? -ne 0 ]; then
  echo "FIXME: release majordomo_cosim_test build failed"
  exit 1
fi

popd

############################## goldmem debug BUILD
pushd .
mkdir -p goldd
cd goldd
cmake -DCMAKE_BUILD_TYPE=Debug -DGOLDMEM=On $majordomo_root

make -j majordomo_cosim_test
if [ $? -ne 0 ]; then
  echo "FIXME: goldmem debug build failed"
  exit 1
fi

popd

############################## create trace

./release/majordomo --maxinsns 10k --trace 0 --ncpus 2 $majordomo_root/riscv-simple-tests/rv64ua-p-amoxor_d 2>check1.trace
if [ $? -ne 0 ]; then
  echo "FIXME: failed to create a release trace"
  exit 1
fi

./debug/majordomo --maxinsns 10k --trace 0 --ncpus 2 $majordomo_root/riscv-simple-tests/rv64ua-p-amoxor_d 2>check2.trace
if [ $? -ne 0 ]; then
  echo "FIXME: failed to create a debug trace"
  exit 1
fi

cmp check1.trace check2.trace
if [ $? -ne 0 ]; then
  echo "FIXME: debug and release trace do not match"
  exit 1
fi


############################## check trace

./release/majordomo_cosim_test  cosim check1.trace --ncpus 2 ../riscv-simple-tests/rv64ua-p-amoxor_d
if [ $? -ne 0 ]; then
  echo "FIXME: release check trace failed"
  exit 1
fi

./debug/majordomo_cosim_test  cosim check1.trace --ncpus 2 ../riscv-simple-tests/rv64ua-p-amoxor_d
if [ $? -ne 0 ]; then
  echo "FIXME: debug check trace failed"
  exit 1
fi

############################## check goldmem

./gold/majordomo_cosim_test  cosim check1.trace --ncpus 2 ../riscv-simple-tests/rv64ua-p-amoxor_d
if [ $? -ne 0 ]; then
  echo "FIXME: golemem debug check trace failed"
  exit 1
fi

echo "SUCCESS!!! the small regression passed!"

