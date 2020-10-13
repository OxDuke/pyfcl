# NOTE: this docker file is only for local testing of the build

# This is from Docker hub's clean-slate Ubuntu16.04
FROM ubuntu:16.04

# Set a directory
WORKDIR /usr/src/app

# Copy files
COPY . .

# Now let's install some dependencies
# g++, cmake, git
# python, numpy

RUN apt-get update
RUN apt-get install -y g++ git cmake
RUN apt-get install -y libeigen3-dev

# Check version
RUN g++ --version
RUN git --version
RUN cmake --version

# clone FCL and libccd
# the exact checkouts are in clone.bash
# COPY requirements/clone.bash .
RUN bash requirements/clone.bash

RUN bash requirements/install_eigen3.bash

# build and install libccd and fcl using cmake
# COPY requirements/build.bash .
RUN bash requirements/build.bash

# Install python3.7 & pip
RUN apt-get install -y python3.7-dev
RUN python3.7 -m pip install pip
RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install numpy cython

# python3.7 -m pip install pip
#RUN python --version


########## Below to install python3.7
# sudo apt update
# sudo apt install software-properties-common

# sudo add-apt-repository ppa:deadsnakes/ppa


# sudo apt update
# sudo apt install python3.7
