from __future__ import print_function, division

import numpy as np
import unittest

import fcl

from common_utils import double_float_difference

def check_signed_distance(shape1, shape2, tf1, tf2, signed_distance, atol=0):
    co1 = fcl.CollisionObject(shape1, tf1)
    co2 = fcl.CollisionObject(shape2, tf2) 

    req = fcl.DistanceRequest(enable_signed_distance=True)
    res = fcl.DistanceResult()

    ret = fcl.distance(co1, co2, req, res)

    np.testing.assert_allclose(res.min_distance,
                               signed_distance,
                               rtol=0,
                               atol=atol + double_float_difference)


class TestDistance(unittest.TestCase):

    def test_sphere_sphere_signed(self):

        s1, s2 = fcl.Sphere(1), fcl.Sphere(2)
        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))
        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0.1, 0, 0]))
        
        check_signed_distance(s1, s2, tf1, tf2, -2.9, 1.1e-6)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([1, 0, 0]))
        check_signed_distance(s1, s2, tf1, tf2, -2, 1e-6)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([3, 0, 0]))
        check_signed_distance(s1, s2, tf1, tf2, 0, 1e-6)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([4, 0, 0]))
        check_signed_distance(s1, s2, tf1, tf2, 1, 1e-6)

    def test_box_sphere_signed(self):
        b, s = fcl.Box(1,2,3), fcl.Sphere(1)
        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))
        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0.1, 0, 0]))
        
        check_signed_distance(b, s, tf1, tf2, -1.4, 1e-7)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([1, 0, 0]))
        check_signed_distance(b, s, tf1, tf2, -0.5, 1e-7)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([2, 0, 0]))
        check_signed_distance(b, s, tf1, tf2, 0.5, 0)

    def test_convex_convex_signed_tetrahedron(self):
        """
        Convex shape is a tetrahedron.
        """
        vertices = np.array([[0, 0, 1], [0, 0, 0], [0, 1, 0], [1, 0, 0]])
        faces = [[0, 2, 1], [0, 1, 3], [0, 3, 2], [1, 2, 3]]

        nfaces = [len(face) for face in faces]
        cfaces = [[pair[0]] + pair[1] for pair in zip(nfaces, faces)]
        cfaces = [item for sublist in cfaces for item in sublist]

        c1 = fcl.Convex(vertices, 4, cfaces)

        vertices = np.array([[0, 0, 1], [0, 0, 0], [-1, 0, 0], [0, 1, 0]])
        c2 = fcl.Convex(vertices, 4, cfaces)

        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))
        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))

        check_signed_distance(c1, c2, tf1, tf2, 0, 0)

        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([1, 0, 0]))
        check_signed_distance(c1, c2, tf1, tf2, 1, 0)

        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([-0.1, 0, 0]))
        check_signed_distance(c1, c2, tf1, tf2, -0.1, 1e-7)

        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([-0.2, 0, 0]))
        check_signed_distance(c1, c2, tf1, tf2, -0.2, 1e-7)

    def test_convextetrahedron_box_signed(self):
        vertices = np.array([[0, 0, 1], [0, 0, 0], [0, 1, 0], [1, 0, 0]])
        faces = [[0, 2, 1], [0, 1, 3], [0, 3, 2], [1, 2, 3]]

        nfaces = [len(face) for face in faces]
        cfaces = [[pair[0]] + pair[1] for pair in zip(nfaces, faces)]
        cfaces = [item for sublist in cfaces for item in sublist]

        c = fcl.Convex(vertices, 4, cfaces)
        b = fcl.Box(1,2,3)

        tf1 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))
        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([-1, 0, 0]))

        check_signed_distance(c, b, tf1, tf2, 0.5, 0)

        tf2 = fcl.Transform(np.array([1, 0, 0, 0]), np.array([0, 0, 0]))
        check_signed_distance(c, b, tf1, tf2, -0.5, 0)


if __name__ == "__main__":
    unittest.main()