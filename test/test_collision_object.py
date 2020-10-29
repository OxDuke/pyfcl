
#!/usr/bin/env python

from __future__ import print_function, division

import numpy as np
import unittest

import tf.transformations as tfm

import fcl

class TestCollisionObject(unittest.TestCase):
    def test_setQuatRotation(self):
        co = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0])))

        co.setQuatRotation([1,0,0,0])
        print(co.getQuatRotation())


if __name__ == "__main__":
    #TestCollisionObject.test_setQuatRotation
    #c.test_setQuatRotation()

    co = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0])))
    print(co.getQuatRotation())

    rq = tfm.random_quaternion()
    rq_fcl = np.roll(rq, 1)

    new_tf = fcl.Transform(rq_fcl, np.array([0,0,0]))
    co.setTransform(new_tf)

    #co.setQuatRotation([1,0,0,0])
    print("rq: ", rq_fcl)
    print(co.getQuatRotation())
    print(co.getRotation())
    print(tfm.quaternion_matrix(np.roll(co.getQuatRotation(), -1)))
    print(tfm.quaternion_matrix(rq))
    print(co.getTransform().toarray())
    #print(co.getTransform().linear)
