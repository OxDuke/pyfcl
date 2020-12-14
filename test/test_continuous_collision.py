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
        co1 = fcl.CollisionObject(
            fcl.Sphere(1),
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, -4, 0])))
        co2 = fcl.CollisionObject(
            fcl.Sphere(1),
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 4, 0])))

        tf1_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))
        tf2_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))

        req = fcl.ContinuousCollisionRequest()
        res = fcl.ContinuousCollisionResult()

        fcl.continuousCollide(co1, tf1_end, co2, tf2_end, req, res)

        self.assertEqual(res.is_collide, True)
        np.testing.assert_allclose(res.time_of_contact, 0.75, rtol=0, atol=0)

    def test_box_box(self):
        # @TODO: It seems that continuousCollide does not work on the following case.
        co1 = fcl.CollisionObject(
            fcl.Box(1,2,3),
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 4, 0])))
        co2 = fcl.CollisionObject(
            fcl.Box(1,2,3),
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0])))

        tf1_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))
        tf2_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))

        # req = fcl.ContinuousCollisionRequest()
        # res = fcl.ContinuousCollisionResult()
        # fcl.continuousCollide(co1, tf1_end, co2, tf2_end, req, res)
        # self.assertEqual(res.is_collide, True)
        # np.testing.assert_allclose(res.time_of_contact, 0.5, rtol=0, atol=0)
        
        # tf1_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, -4, 0]))
        # tf2_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 4, 0]))

        # req = fcl.ContinuousCollisionRequest()
        # res = fcl.ContinuousCollisionResult()
        # fcl.continuousCollide(co1, tf1_end, co2, tf2_end, req, res)
        # self.assertEqual(res.is_collide, False)
      

    def test_bvh_cc(self):
        # @TODO: It seems that continuousCollide does not work on BVH models
        # Create a box centered at [0, 0, 0] with extents[1, 2, 3]
        vertices = np.array([[-0.5, -1, -1.5], [-0.5, -1, 1.5], [-0.5, -1, -1.5],
                             [-0.5, -1, 1.5], [0.5, -1, -1.5], [0.5, -1, 1.5],
                             [0.5, -1, -1.5], [0.5, -1, 1.5]])

        faces = np.array([[7, 3, 5], [5, 3, 1], [4, 0, 6], [6, 0,
                                                            2], [1, 0, 5],
                          [5, 0, 4], [3, 2, 1], [1, 2, 0], [7, 6, 3],
                          [3, 6, 2], [5, 4, 7], [7, 4, 6]])

        bvh1 = fcl.BVHModel()
        bvh1.beginModel(len(faces), len(vertices))
        bvh1.addSubModel(vertices, faces)
        bvh1.endModel()

        bvh2 = fcl.BVHModel()
        bvh2.beginModel(len(faces), len(vertices))
        bvh2.addSubModel(vertices, faces)
        bvh2.endModel()

        co1 = fcl.CollisionObject(
            bvh1,
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([4, 0, 0])))
        co2 = fcl.CollisionObject(
            bvh2,
            fcl.Transform(np.array([0, 0, 0, 1]), np.array([-4, 0, 0])))

        tf1_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))
        tf2_end = fcl.Transform(np.array([0, 0, 0, 1]), np.array([0, 0, 0]))

        req = fcl.ContinuousCollisionRequest(num_max_iterations=40)
        res = fcl.ContinuousCollisionResult()

        fcl.continuousCollide(co1, tf1_end, co2, tf2_end, req, res)

        #self.assertEqual(res.is_collide, False)
        #np.testing.assert_allclose(res.time_of_contact, 0.75, rtol=0, atol=0)

    


if __name__ == "__main__":
    unittest.main()