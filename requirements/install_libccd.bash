#!/usr/bin/env bash

rm -rf libccd
git clone https://github.com/danfis/libccd.git
cd libccd
git checkout v2.1

rm -rf build && mkdir build && cd build
cmake ..
make -j4 && make install
cd ../.

rm -rf libccd