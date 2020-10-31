#!/usr/bin/env bash

# Clone Fcl
rm -rf fcl
git clone https://github.com/flexible-collision-library/fcl.git
cd fcl
git checkout v0.6.1

# Build & Install
rm -rf build && mkdir build && cd build
cmake -DFCL_BUILD_TESTS=OFF ..
make -j4 && make install
cd ../..

# Remove source
rm -rf fcl