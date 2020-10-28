# NOTE: this docker file is only for local testing of the build

# This is from Docker hub's clean-slate Ubuntu16.04
FROM ubuntu:16.04

# Set a directory
WORKDIR /usr/src/app

# Now let's install some dependencies
# g++, cmake, git
# python, numpy

RUN apt-get update && apt-get install -y \
	g++ git cmake sudo \
	libeigen3-dev

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y build-essential python3.7 python3.7-dev python3-pip

RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install wheel numpy cython

# Copy files
WORKDIR /usr/src/app/pyfcl
COPY . .

# Set a directory
WORKDIR /usr/src/app
# Download & build & install dependencies
RUN apt-get -y install liboctomap-dev
RUN bash pyfcl/requirements/clone.bash && \
	bash pyfcl/requirements/build.bash
