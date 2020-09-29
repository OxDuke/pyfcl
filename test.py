from __future__ import print_function, division

from pyfcl import Vector3, Sphere

v = Vector3(1,2,3)
print(v[0], v[1], v[2])
v[0] = 5
print(v[0])

s = Sphere(3)
print(s.radius)
s.radius = 1
print(s.radius)