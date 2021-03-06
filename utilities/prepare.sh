#!/bin/bash -e

set -e

echo This script downloads the code for the benchmarks
echo It will also attempt to build the benchmarks
echo It will output OK at the end if builds succeed
echo

IOR_HASH=e1968cd4ad50d3d5dee853ae3b1a8724f4f072c7
MDREAL_HASH=f1f4269666bc58056a122a742dc5ca13be5a79f5

INSTALL_DIR=$PWD
BIN=$INSTALL_DIR/bin
BUILD=$PWD/build
MAKE="make -j4"

function main {
  # listed here, easier to spot and run if something fails
  setup

  get_ior
  get_pfind
  #get_mdrealio || true  # this failed on RHEL 7.4 so turning off until fixed

  build_ior
#  build_pfind   # unnecessary since it is a Python 3 program
#  build_mdrealio || true  # this failed on RHEL 7.4 so turning off until fixed

  echo
  echo "OK: All required software packages are now prepared"
  ls $BIN
}

function setup {
  rm -rf $BUILD $BIN
  mkdir -p $BUILD $BIN 
  cp utilities/io500_fixed.sh utilities/find/sfind.sh $BIN
}

function git_co {
  pushd $BUILD
  git clone $1
  cd $2
  # turning off the hash thing for now because too many changes happening too quickly
  #git checkout $3
  popd
}

###### GET FUNCTIONS
function get_ior {
  echo "Getting IOR and mdtest"
  git_co https://github.com/IOR-LANL/ior ior $IOR_HASH
  pushd $BUILD/ior
  ./bootstrap
  ./configure --prefix=$INSTALL_DIR
  popd
}

function get_pfind {
  echo "Preparing parallel find"
  pushd $BUILD
  rm -rf pwalk
  git clone https://github.com/johnbent/pwalk.git
  cp -r pwalk/pfind pwalk/lib $BIN
  echo "Pfind: OK"
  echo
  popd
}

function get_mdrealio {
  echo "Preparing MD-REAL-IO"
  git_co https://github.com/JulianKunkel/md-real-io md-real-io $MDREAL_HASH
  pushd $BUILD/md-real-io
  ./configure --prefix=$INSTALL_DIR --minimal
  popd
}

###### BUILD FUNCTIONS
function build_ior {
  pushd $BUILD
  cd ior/src # just build the source
  $MAKE install
  echo "IOR: OK"
  echo
  popd
}

function build_mdrealio {
  cd $BUILD/md-real-io
  pushd build
  $MAKE install
  #mv src/md-real-io $BIN
  echo "MD-REAL-IO: OK"
  echo
  popd
}

###### CALL MAIN
main
