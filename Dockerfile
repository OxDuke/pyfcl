# NOTE: this docker file is only for local testing of the build

# This is from Docker hub's clean-slate Ubuntu16.04
FROM ubuntu:16.04

# Set a directory
WORKDIR /usr/src/app

# Now let's install some dependencies
# g++, cmake, git
# python, numpy

RUN apt-get update
RUN apt-get install -y g++ git cmake sudo 
RUN apt-get install -y libeigen3-dev

# Check version
RUN g++ --version
RUN git --version
RUN cmake --version

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y build-essential python3.7 python3.7-dev python3-pip

RUN python3.7 -m pip install pip --upgrade
RUN python3.7 -m pip install wheel
RUN python3.7 -m pip install numpy cython


# Copy files
WORKDIR /usr/src/pyfcl
COPY . .

# Download & build & install dependencies
RUN bash requirements/clone.bash
RUN bash requirements/install_eigen3.bash
RUN bash requirements/build.bash