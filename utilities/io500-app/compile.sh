#!/bin/bash -x
CC=mpicc
CFLAGS="-g -O2 -Wall"

pushd ior-1
echo "Building IOR + MDTEST"

$CC -DHAVE_CONFIG_H -I. $CFLAGS -Dmain=main_ior -c -o ior-ior.o src/ior.c
$CC -DHAVE_CONFIG_H -I. $CFLAGS -c -o ior-utilities.o src/utilities.c
$CC -DHAVE_CONFIG_H -I. $CFLAGS -c -o ior-aiori.o src/aiori.c
$CC -DHAVE_CONFIG_H -I. $CFLAGS -c -o ior-parse_options.o src/parse_options.c
$CC -DHAVE_CONFIG_H -I. $CFLAGS -c -o ior-aiori-MPIIO.o src/aiori-MPIIO.c
$CC -DHAVE_CONFIG_H -I. $CFLAGS -c -o ior-aiori-POSIX.o src/aiori-POSIX.c
$CC $CFLAGS -DLinux -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE=1 -D__USE_LARGEFILE64=1 -Dmain=main_mdtest -c src/mdtest.c
popd

echo "Building IO500"
$CC $CFLAGS -I ior-1/src -c src/io500-core.c
$CC $CFLAGS -I ior-1/src -c src/io500-find.c
$CC $CFLAGS -o io500 ior-1/*.o *.o -lm