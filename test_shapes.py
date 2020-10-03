from __future__ import print_function, division

import numpy as np
import unittest

import pyfcl as fcl

def test_shape_self_collide(shape1, shape2, tf1, tf2, is_in_collision):
    co1 = fcl.CollisionObject(shape1, tf1)
    co2 = fcl.CollisionObject(shape2, tf2)

    req = fcl.CollisionRequest()
    res = fcl.CollisionResult()

    ret = fcl.collide(co1, co2, req, res)

    assert res.is_collision == is_in_collision

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
        random_sides = np.random.rand(3)
        box = fcl.Box(*random_sides)
        np.testing.assert_allclose(box.side, random_sides, rtol=0, atol=0)
        
        random_sides = np.random.rand(3)
        box.side = random_sides
        np.testing.assert_allclose(box.side, random_sides, rtol=0, atol=0)

        self.assertTrue(box.getNodeType() == 9)
        print(box.aabb_center)

    def test_self_collide(self):
        # Seperate on X axis
        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0.999,0,0])),
            True)

        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1.001,0,0])),
            False)
        
        # Seperate on Y axis
        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 1.499, 0])),
            True)

        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,1.501, 0])),
            False)

        # Seperate on Z axis
        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 0,1.999])),
            True)

        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0, 2.001])),
            False)

        # Rotate box1 around Z axis for 90 degrees
        # Note that the quaternion is in [w,x,y,z] order.
        rotate_around_z_90_degrees = np.array([0.70710678, 0., 0., 0.70710678])
        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([1.499,0,0])),
            fcl.Transform(rotate_around_z_90_degrees, np.array([0,0,0])),
            True)
        test_shape_self_collide(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([1.501,0,0])),
            fcl.Transform(rotate_around_z_90_degrees, np.array([0,0,0])),
            False)

class TestSphere(unittest.TestCase):

    def test_properties(self):
        random_radius = np.random.rand()
        sphere = fcl.Sphere(random_radius)
        np.testing.assert_allclose(sphere.radius, random_radius, rtol=0, atol=0)

        random_radius = np.random.rand()
        sphere.radius = random_radius
        np.testing.assert_allclose(sphere.radius, random_radius, rtol=0, atol=0)

        self.assertTrue(sphere.getNodeType() == 10)

    def test_self_collide(self):
        test_shape_self_collide(fcl.Sphere(1), fcl.Sphere(2), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2.999,0,0])),
            True)

        test_shape_self_collide(fcl.Sphere(1), fcl.Sphere(2), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([3.001,0,0])),
            False)

class TestEllipsoid(unittest.TestCase):
    def test_properties(self):
        random_radii = np.random.rand(3)
        ellipsoid = fcl.Ellipsoid(random_radii[0], random_radii[1], random_radii[2])
        np.testing.assert_allclose(ellipsoid.radii, random_radii, rtol=0, atol=0)

        random_radii = np.random.rand(3)
        ellipsoid.radii = random_radii
        np.testing.assert_allclose(ellipsoid.radii, random_radii, rtol=0, atol=0)

    def test_self_collide(self):
        e1, e2 = fcl.Ellipsoid(1, 2, 3), fcl.Ellipsoid(1, 2, 3), 
        
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1.999,0,0])),
            True)
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2.001,0,0])),
            False)

        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 3.999, 0])),
            True)
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 4.001, 0])),
            False)

        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 0, 5.999])),
            True)
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 0, 6.001])),
            False)

        rotate_around_x_90_degrees = np.array([0.70710678, 0.70710678, 0., 0.])
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,2.999,0])),
            fcl.Transform(rotate_around_x_90_degrees, np.array([0, 4.999, 0])),
            True)
        test_shape_self_collide(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(rotate_around_x_90_degrees, np.array([0, 5.001, 0])),
            False)


        

if __name__ == '__main__':
    unittest.main()
        