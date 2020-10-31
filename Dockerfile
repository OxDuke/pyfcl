# NOTE: this docker file is only for local testing of the build

# This is from Docker hub's clean-slate Ubuntu16.04
FROM ubuntu:16.04

# Set a directory
WORKDIR /usr/src/app

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \
	g++ git cmake sudo \
	libeigen3-dev \
	software-properties-common \
	build-essential python3.7 python3.7-dev python3-pip

RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install wheel numpy cython

# Copy files
WORKDIR /usr/src/app/pyfcl
COPY . .

# Set a directory
WORKDIR /usr/src/app
# Download & build & install dependencies
RUN bash pyfcl/requirements/install_libccd.bash && \
    bash pyfcl/requirements/install_octomap.bash && \
    bash pyfcl/requirements/install_fcl.bash
