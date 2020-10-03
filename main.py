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

tf.linear = np.array([[1,2,3],[4,5,6],[7,8,9]])
print("linear:", tf.linear[0], tf.linear[1], tf.linear[2], tf.linear[3], tf.linear[4])
tf.translation = pyfcl.Vector3(10,20,30)
print("translation: ", tf.translation.x, tf.translation.y, tf.translation.z)

co = pyfcl.CollisionObject(s, tf)
print(co.getNodeType())
print(co.getObjectType())

print("co tr:", co.getTranslation())
co.setTranslation(np.array([99,98,97]))
print("co tr:", co.getTranslation())

print("co rot: ", co.getRotation())
co.setRotation(np.random.rand(3,3))
print("co rot: ", co.getRotation())

print("co quat: ", co.getQuatRotation())
rquat = np.random.rand(4)
rquat = rquat / np.linalg.norm(rquat)
co.setQuatRotation(rquat)
print("co quat: ", co.getQuatRotation(), rquat)

print("co tf: ", co.getTranslation(), co.getQuatRotation())
print("tf: ", tf)
co.setTransform(tf)
print("co tf: ", co.getTranslation(), co.getQuatRotation())


s1 = pyfcl.Sphere(1)
s2 = pyfcl.Sphere(1)

#s1 = pyfcl.Sphere(1)
#s2 = pyfcl.Box(1, 1, 1)

tf1 = pyfcl.Transform()
tf1.linear = np.eye(3)
tf1.translation = [0, 0, 0]

tf2 = pyfcl.Transform()
tf2.linear = np.eye(3)
tf2.translation = [1,0,0]

co1 = pyfcl.CollisionObject(s1, tf1)
co2 = pyfcl.CollisionObject(s2, tf2)

req = pyfcl.CollisionRequest(num_max_contacts = 10, enable_contact=True)
res = pyfcl.CollisionResult()

ret = pyfcl.collide(co1, co2, req, res)

print("In collision? ", res.is_collision)
if (res.is_collision):
    print("geom1, geom2: ", s1, s2)
    print("Contact info")
    for cntc in res.contacts:
        print("o1, o2: ", cntc.o1, cntc.o2)
        print("PD: ", cntc.penetration_depth)
    #print("Depth: ", res.penetration_depth)

def kk():
    req = pyfcl.CollisionRequest(num_max_contacts = 10, enable_contact=True)
    res = pyfcl.CollisionResult()

    ret = pyfcl.collide(co1, co2, req, res)

#%timeit kk
#%timeit tf.translation = [5,6,7]

# t = TriangleP(np.array([0,0,0]), np.array([1,0,0]), np.array([0,1,0]))
# print(t.a, t.b, t.c)

