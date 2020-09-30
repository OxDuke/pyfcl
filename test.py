from __future__ import print_function, division

import numpy as np

import unittest

import pyfcl 

v = pyfcl.Vector3(1,2,3)
print(v[0], v[1], v[2])
v[0] = 5
print(v[0])

s = pyfcl.Sphere(3)
print(s.radius)
s.radius = 1
print(s.radius)

print(type(pyfcl.hello_fcl()))

q = pyfcl.Quaternion(1,2,3,4)
print(q.w,q.x,q.y,q.z)

# t = TriangleP(np.array([0,0,0]), np.array([1,0,0]), np.array([0,1,0]))
# print(t.a, t.b, t.c)