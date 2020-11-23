"""
  @AUTHOR: Weidong Sun
  @EMAIL: 464604837@qq.com
"""

from __future__ import print_function, division

import numpy as np
import unittest

import fcl

class TestContinuousCollision(unittest.TestCase):
    def test_sphere_cc(self):
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,-4,0])))
        co2 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))

        tf1_end = fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0]))
        tf2_end = fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0]))

        req = fcl.ContinuousCollisionRequest()
        res = fcl.ContinuousCollisionResult()

        fcl.continuousCollide(co1, tf1_end, co2, tf2_end, req, res)

        self.assertEqual(res.is_collide, True)
        np.testing.assert_allclose(res.time_of_contact, 0.75, rtol=0, atol=0)

        
if __name__ == "__main__":
    unittest.main()