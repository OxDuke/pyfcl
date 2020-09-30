from __future__ import print_function, division

import numpy as np
import unittest

import pyfcl as fcl

class TestTriangleP(unittest.TestCase):
    def test_properties(self):
        
        random_vertices = [np.random.rand(3)for i in range(3)]
        tri = fcl.TriangleP(*random_vertices)
        np.testing.assert_allclose(tri.a, random_vertices[0], rtol=0, atol=0)
        np.testing.assert_allclose(tri.b, random_vertices[1], rtol=0, atol=0)
        np.testing.assert_allclose(tri.c, random_vertices[2], rtol=0, atol=0)

        random_vertices = [np.random.rand(3)for i in range(3)]
        tri.a, tri.b, tri.c = random_vertices
        np.testing.assert_allclose(tri.a, random_vertices[0], rtol=0, atol=0)
        np.testing.assert_allclose(tri.b, random_vertices[1], rtol=0, atol=0)
        np.testing.assert_allclose(tri.c, random_vertices[2], rtol=0, atol=0)

class TestBox(unittest.TestCase):
    def test_properties(self):
        pass



class TestSphere(unittest.TestCase):

    def test_properties(self):

        random_radius = np.random.rand()
        sphere = fcl.Sphere(random_radius)
        np.testing.assert_allclose(sphere.radius, random_radius, rtol=0, atol=0)

        random_radius = np.random.rand()
        sphere.radius = random_radius
        np.testing.assert_allclose(sphere.radius, random_radius, rtol=0, atol=0)

if __name__ == '__main__':
    unittest.main()
        