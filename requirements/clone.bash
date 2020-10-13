rm -rf libccd
git clone https://github.com/danfis/libccd.git
cd libccd
git pull
git checkout v2.1
cd ..

rm -rf octomap 
git clone https://github.com/OctoMap/octomap.git
cd octomap
git pull
# I have tried v.1.9.5, didn't work: https://github.com/flexible-collision-library/fcl/issues/210
git checkout v1.8.1
cd ..

rm -rf fcl
git clone https://github.com/flexible-collision-library/fcl.git
cd fcl
git pull
git checkout v0.6.1
cd ..

# get eigen
#curl -OL https://github.com/RLovelett/eigen/archive/3.3.4.tar.gz
#tar -zxvf 3.3.4.tar.gz
