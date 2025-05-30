# See LICENSE for license details.

#*****************************************************************************
# fli_s.S
#-----------------------------------------------------------------------------
#
# Test f{min|max}.h instructinos.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64UF
RVTEST_CODE_BEGIN

#rs1 Value                    S Exp(8)   Sig(23)
#0  \(-1.0\)                1_01111111_000_0000_0000_0000_0000_0000 0xBF800000
#1  Minimum positive normal 0_00000001_000_0000_0000_0000_0000_0000 0x00800000
#2  \(1.0 \times 2^{-16}\)  0_01101111_000_0000_0000_0000_0000_0000 0x37800000
#3  \(1.0 \times 2^{-15}\)  0_01110000_000_0000_0000_0000_0000_0000 0x38000000
#4  \(1.0 \times 2^{-8}\)   0_01110111_000_0000_0000_0000_0000_0000 0x3B800000
#5  \(1.0 \times 2^{-7}\)   0_01111000_000_0000_0000_0000_0000_0000 0x3C000000
#6  0.0625 (\(2^{-4}\))     0_01111011_000_0000_0000_0000_0000_0000 0x3D800000
#7  0.125 (\(2^{-3}\))      0_01111100_000_0000_0000_0000_0000_0000 0x3E000000
#8  0.25                    0_01111101_000_0000_0000_0000_0000_0000 0x3E800000
#9  0.3125                  0_01111101_000_0000_0000_0000_0001_0000 0x3E800010
#10 0.375                   0_01111101_000_0000_0000_0000_0010_0000 0x3E800020
#11 0.4375                  0_01111101_000_0000_0000_0000_0011_0000 0x3E800030
#12 0.5                     0_01111110_000_0000_0000_0000_0000_0000 0x3F000000
#13 0.625                   0_01111110_000_0000_0000_0000_0001_0000 0x3F000010
#14 0.75                    0_01111110_000_0000_0000_0000_0010_0000 0x3F000020
#15 0.875                   0_01111110_000_0000_0000_0000_0011_0000 0x3F000030
#16 1.0                     0_01111111_000_0000_0000_0000_0000_0000 0x3F800000
#17 1.25                    0_01111111_000_0000_0000_0000_0001_0000 0x3F800010
#18 1.5                     0_01111111_000_0000_0000_0000_0010_0000 0x3F800020
#19 1.75                    0_01111111_000_0000_0000_0000_0011_0000 0x3F800030
#20 2.0                     0_10000000_000_0000_0000_0000_0000_0000 0x40000000
#21 2.5                     0_10000000_000_0000_0000_0000_0001_0000 0x40000010
#22 3                       0_10000000_000_0000_0000_0000_0010_0000 0x40000020
#23 4                       0_10000001_000_0000_0000_0000_0000_0000 0x40800000
#24 8                       0_10000010_000_0000_0000_0000_0000_0000 0x41000000
#25 16                      0_10000011_000_0000_0000_0000_0000_0000 0x41800000
#26 128 (\(2^7\))           0_10000110_000_0000_0000_0000_0000_0000 0x43000000
#27 256 (\(2^8\))           0_10000111_000_0000_0000_0000_0000_0000 0x43800000
#28 \(2^{15}\)              0_10001110_000_0000_0000_0000_0000_0000 0x47000000
#29 \(2^{16}\)              0_10001111_000_0000_0000_0000_0000_0000 0x47800000
#30 \(+\infty\)             0_11111111_000_0000_0000_0000_0000_0000 0x7F800000
#31 Canonical NaN           0_11111111_000_0000_0000_0000_0010_0000 0x7F800020

# representing the minimum positive, index 1, is stupidly complicated
# 1.1754943508222875079687365372222e-38, good luck

  fli.s f1, min
# fli.s f1, ????                # 1
  fli.s f1,  0.0000152587890625 # 2
  fli.s f1,  0.000030517578125  # 3 
  fli.s f1,  0.00390625         # 4 
  fli.s f1,  0.0078125          # 5
  fli.s f1,  0.625              # 6
  fli.s f1,  0.125              # 7 
  fli.s f1,  0.25               # 8 
  fli.s f1,  0.3125             # 9 
  fli.s f1,  0.375              # 10 
  fli.s f1,  0.4375             # 11 
  fli.s f1,  0.5                # 12 
  fli.s f1,  0.625              # 13 
  fli.s f1,  0.75               # 14 
  fli.s f1,  0.875              # 15 
  fli.s f1,  1.0                # 16 
  fli.s f1,  1.25               # 17 
  fli.s f1,  1.5                # 18 
  fli.s f1,  1.75               # 19 
  fli.s f1,  2.0                # 20 
  fli.s f1,  2.5                # 21 
  fli.s f1,  3                  # 22 
  fli.s f1,  4                  # 23 
  fli.s f1,  8                  # 24 
  fli.s f1,  16                 # 25 
  fli.s f1,  128                # 26 
  fli.s f1,  256                # 27 
  fli.s f1,  32768              # 28 
  fli.s f1,  65536              # 29 
  fli.s f1, inf
  fli.s f1, nan

#  ------------------------------------------------------------------------
#  FIXME need to find the macros that support this
#  ------------------------------------------------------------------------
#  TEST_CASE( 2, f1, 0xBF800000, fli.s f1, min);
#  TEST_CASE( 3, f1, 0x00800000, fli.s f1,  1 );
#  TEST_CASE( 4, f1, 0x37800000, fli.s f1,  2 );
#  TEST_CASE( 5, f1, 0x38000000, fli.s f1,  3 );
#  TEST_CASE( 6, f1, 0x3B800000, fli.s f1,  4 );
#  TEST_CASE( 7, f1, 0x3C000000, fli.s f1,  5 );
#  TEST_CASE( 8, f1, 0x3D800000, fli.s f1,  6 );
#  TEST_CASE( 9, f1, 0x3E000000, fli.s f1,  7 );
#  TEST_CASE(10, f1, 0x3E800000, fli.s f1,  8 );
#  TEST_CASE(11, f1, 0x3E800010, fli.s f1,  9 );
#  TEST_CASE(12, f1, 0x3E800020, fli.s f1, 10 );
#  TEST_CASE(13, f1, 0x3E800030, fli.s f1, 11 );
#  TEST_CASE(14, f1, 0x3F000000, fli.s f1, 12 );
#  TEST_CASE(15, f1, 0x3F000010, fli.s f1, 13 );
#  TEST_CASE(16, f1, 0x3F000020, fli.s f1, 14 );
#  TEST_CASE(17, f1, 0x3F000030, fli.s f1, 15 );
#  TEST_CASE(18, f1, 0x3F800000, fli.s f1, 16 );
#  TEST_CASE(19, f1, 0x3F800010, fli.s f1, 17 );
#  TEST_CASE(20, f1, 0x3F800020, fli.s f1, 18 );
#  TEST_CASE(21, f1, 0x3F800030, fli.s f1, 19 );
#  TEST_CASE(22, f1, 0x40000000, fli.s f1, 20 );
#  TEST_CASE(23, f1, 0x40000010, fli.s f1, 21 );
#  TEST_CASE(24, f1, 0x40000020, fli.s f1, 22 );
#  TEST_CASE(25, f1, 0x40800000, fli.s f1, 23 );
#  TEST_CASE(26, f1, 0x41000000, fli.s f1, 24 );
#  TEST_CASE(27, f1, 0x41800000, fli.s f1, 25 );
#  TEST_CASE(28, f1, 0x43000000, fli.s f1, 26 );
#  TEST_CASE(29, f1, 0x43800000, fli.s f1, 27 );
#  TEST_CASE(30, f1, 0x47000000, fli.s f1, 28 );
#  TEST_CASE(31, f1, 0x47800000, fli.s f1, 29 );
#  TEST_CASE(32, f1, 0x7F800000, fli.s f1, inf);
#  TEST_CASE(33, f1, 0x7F800020, fli.s f1, nan);

  # Add expect data check
  # TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
