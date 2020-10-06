"""
  @AUTHOR: Weidong Sun
  @EMAIL: swdswd28@foxmail.com
"""

from __future__ import print_function, division

import numpy as np
import unittest

import pyfcl as fcl

def nonzero_rand(*args):
    return np.random.rand(*args) + 0.05

def test_shape_self_collide(shape1, shape2, tf1, tf2, is_in_collision):
    co1 = fcl.CollisionObject(shape1, tf1)
    co2 = fcl.CollisionObject(shape2, tf2)

    req = fcl.CollisionRequest()
    res = fcl.CollisionResult()

    ret = fcl.collide(co1, co2, req, res)

    assert res.is_collision == is_in_collision

def test_shape_self_distance(shape1, shape2, tf1, tf2, expected_distance, atol=0):
    co1 = fcl.CollisionObject(shape1, tf1)
    co2 = fcl.CollisionObject(shape2, tf2)

    req = fcl.DistanceRequest()
    res = fcl.DistanceResult()

    ret = fcl.distance(co1, co2, req, res)

    np.testing.assert_allclose(res.min_distance, expected_distance, rtol=0, atol=atol)

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

    def test_self_collide(self):
        # t1 = fcl.TriangleP(*np.array([[0,0,0],[1,0,0],[0,1,0]]))
        # t2 = fcl.TriangleP(*np.array([[0,1,0],[-1,0,0],[1,0,0]]))
        
        # test_shape_self_collide(t1, t2,
        #     fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
        #     fcl.Transform(np.array([0,0,0,1]), np.array([-0.999,0,0])),
        #     True)

        # test_shape_self_collide(t1, t2,
        #     fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
        #     fcl.Transform(np.array([0,0,0,1]), np.array([-1.001,0,0])),
        #     False)
        
        # @TODO: need tests here
        pass

    def test_self_distance(self):
        # @TODO: need tests here
        pass

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

    def test_self_distance(self):
        # Seperation on X, Y, Z axis
        test_shape_self_distance(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2,0,0])),
            1.0)

        test_shape_self_distance(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,3,0])),
            1.5)

        test_shape_self_distance(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,3])),
            1.0)
        
        # If two boxes collide, distance() should return -1.
        test_shape_self_distance(fcl.Box(1,1,1), fcl.Box(1,2,3), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1,0,0])),
            -1.0)

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

    def test_self_distance(self):
        test_shape_self_distance(fcl.Sphere(1), fcl.Sphere(2), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([4,0,0])),
            1.)

        test_shape_self_distance(fcl.Sphere(1), fcl.Sphere(2), 
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2,0,0])),
            -1)

class TestEllipsoid(unittest.TestCase):
    def test_properties(self):
        random_radii = np.random.rand(3)
        ellipsoid = fcl.Ellipsoid(random_radii[0], random_radii[1], random_radii[2])
        np.testing.assert_allclose(ellipsoid.radii, random_radii, rtol=0, atol=0)

        random_radii = np.random.rand(3)
        ellipsoid.radii = random_radii
        np.testing.assert_allclose(ellipsoid.radii, random_radii, rtol=0, atol=0)

    def test_self_collide(self):
        e1, e2 = fcl.Ellipsoid(1, 2, 3), fcl.Ellipsoid(1, 2, 3)
        
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

    def test_self_distance(self):
        e1, e2 = fcl.Ellipsoid(1, 1, 1), fcl.Ellipsoid(1, 2, 3)
        
        test_shape_self_distance(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([3,0,0])),
            1., atol=1e-6)
        test_shape_self_distance(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])),
            1., atol=1e-6)
        test_shape_self_distance(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,5])),
            1., atol=1e-6)

        # Two elliposoids collide
        test_shape_self_distance(e1, e2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1,0,0])),
            -1)

class TestCapsule(unittest.TestCase):
    def test_properties(self):
        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c = fcl.Capsule(random_radius, random_lz)
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c.radius = random_radius
        c.lz = random_lz
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

    def test_self_collide(self):
        c1, c2 = fcl.Capsule(0.5, 2), fcl.Capsule(1, 4)
        
        # Seperation on X-Y plane
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1.499,0,0])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([1.501,0,0])),
            False)
        
        # Seperation on Z axis
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 0, 4.499])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0, 0, 4.501])),
            False)
        
        # Rotate c2 around X axis, then move along Y axis
        rotate_around_x_90_degrees = np.array([0.70710678, 0.70710678, 0., 0.])
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(rotate_around_x_90_degrees, np.array([0,2.499,0])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(rotate_around_x_90_degrees, np.array([0,3.501, 0])),
            False)

    def test_self_distance(self):
        c1, c2 = fcl.Capsule(0.5, 2), fcl.Capsule(1, 4)
        
        # Seperation on X, Y, Z axis
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2,0,0])),
            0.5)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,2,0])),
            0.5)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,5])),
            0.5)

        # If collide, return -0.5? 
        # It should return -1, @TODO: Why? 
        # Maybe it is easier to compute distance between capsules
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,4])),
            -0.5)


class TestCone(unittest.TestCase):
    def test_properties(self):
        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c = fcl.Cone(random_radius, random_lz)
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c.radius = random_radius
        c.lz = random_lz
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

    def test_self_collide(self):
        c1, c2 = fcl.Cone(1, 2), fcl.Cone(2, 4)
        # Seperation on X-Y plane
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2.999,0,1])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([3.001,0,2])),
            False)

        # Seperation on Z axis
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,2.999])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,3.001])),
            False)
        
        # Flip one cone upside down
        c1, c2 = fcl.Cone(1, 2), fcl.Cone(1, 2)
        rotate_around_x_180_degrees = np.array([0,1,0,0])
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,1])),
            fcl.Transform(rotate_around_x_180_degrees, np.array([0,0.999,1])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,1])),
            fcl.Transform(rotate_around_x_180_degrees, np.array([0,1.001,1])),
            False)

    def test_self_distance(self):
        c1, c2 = fcl.Cone(1, 2), fcl.Cone(2, 4)
        # Seperation on X,Y,Z axis
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([4,0,1])),
            1.)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,4,1])),
            1.)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,4])),
            1.)

class TestCylinder(unittest.TestCase):
    def test_properties(self):
        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c = fcl.Cylinder(random_radius, random_lz)
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

        random_radius, random_lz= nonzero_rand(), nonzero_rand()
        c.radius = random_radius
        c.lz = random_lz
        np.testing.assert_allclose(c.radius, random_radius, rtol=0, atol=0)
        np.testing.assert_allclose(c.lz, random_lz, rtol=0, atol=0)

    def test_self_collide(self):
        c1, c2 = fcl.Cylinder(0.5, 1), fcl.Cylinder(2, 4)

        # Seperation on X-Y plane
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2.499,0,1])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([2.501,0,2])),
            False)

        # Seperation on Z axis
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,2.499])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,2.501])),
            False) 

        # Rotate c2 around X axis, then move along Y axis
        rotate_around_x_90_degrees = np.array([0.70710678, 0.70710678, 0., 0.])
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,2.499,0])),
            True)
        test_shape_self_collide(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,3.501,0])),
            False) 

    def test_self_distance(self):
        c1, c2 = fcl.Cylinder(0.5, 1), fcl.Cylinder(2, 4)
        # Seperation on X,Y,Z axis
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([3,0,1])),
            0.5)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,3.5,1])),
            1.0, 1e-5)
        test_shape_self_distance(c1, c2,
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])),
            fcl.Transform(np.array([0,0,0,1]), np.array([0,0,3])),
            0.5)

class TestBVHModel(unittest.TestCase):
    def test_properties(self):
        
        pass

    def test_self_collide(self):
        pass

    #@TODO: Add tests here, we need a more complex mesh.
        

if __name__ == '__main__':
    unittest.main()
        