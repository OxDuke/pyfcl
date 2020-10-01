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
#q.w = 5
#print(q.w)

m = pyfcl.Matrix3()
print(m[0], m[1])
m[0] = 1.0
print(m[0])

tf = pyfcl.Transform()
tf_trans = tf.translation
print("linear:", tf.linear[0], tf.linear[1], tf.linear[2], tf.linear[3], tf.linear[4])
print("translation: ", tf_trans.x, tf_trans.y, tf_trans.z)

tf.linear = [1,2,3,4,5,6,7,8,9]
print("linear:", tf.linear[0], tf.linear[1], tf.linear[2], tf.linear[3], tf.linear[4])
tf.translation = pyfcl.Vector3(10,20,30)
print("translation: ", tf.translation.x, tf.translation.y, tf.translation.z)

co = pyfcl.CollisionObject(s)
print(co.getNodeType())
print(co.getObjectType())

# t = TriangleP(np.array([0,0,0]), np.array([1,0,0]), np.array([0,1,0]))
# print(t.a, t.b, t.c)