PYFCL
=====

Motivation
==========
This package builds upon balabala, which has not been updated since xxx (as of October, 2020).

Major Upgrades
==============
- Support FCL 0.6.0.
- Scalar type: float or double

Differences
***********
- Transform: In contrast to FCL 0.5.0, which implements its own custom Transform data strucutures, FCL 0.6.0 uses Eigen3's `Eigen::Vector3`, `Eigen::Quaternion` and `Eigen::Transform`. A set of C++ wrapper functions are implemented in order to set/get Eigen data strucutres.

- Template: FCL 0.6.0 allows user to choose between `float` and `double` by employing templates in almost all of its APIs. This package also allows user to switch between `float` & `double` for performance or precision. Note that `float` is used by default.


Things to improve
=================
Since Cython was initially designed to bridge between Python and C, not C++. We have to use hacks and walkarounds to cope with C++, especially for features introduced after C++11. I plan to rewrite this package with pybind11.

Upgrade progress
================
working on:
- fcl_defs.pxd

Bookmarks
=========
http://papers.nips.cc/paper/7948-end-to-end-differentiable-physics-for-learning-and-control.pdf

http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=534AC27CD59CFF912BFB6FD8639DD612?doi=10.1.1.476.6683&rep=rep1&type=pdf

https://stackoverflow.com/questions/53582945/wrapping-c-code-with-function-pointer-as-template-parameter-in-cython