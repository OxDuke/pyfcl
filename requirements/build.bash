cd libccd
cmake .
make -j4
sudo make install
cd ..

cd octomap 
cmake .
make -j4
sudo make install
cd ..

cd fcl
cmake -DBUILD_TESTING=OFF .
make -j4
sudo make install
cd ..
