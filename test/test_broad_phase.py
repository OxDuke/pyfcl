"""
  @AUTHOR: Weidong Sun
  @EMAIL: swdswd28@foxmail.com
"""

from __future__ import print_function, division

import numpy as np
import unittest

import pyfcl as fcl

# @TODO: Need to test 3 types of overloading of the manager.collide & manager.distance

class TestDynamicAABBTreeCollisionManager(unittest.TestCase):

    def construct_manager(self):
        # co3 collides with co1
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])))
        co2 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,3,0])))
        co3 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))
        
        manager = fcl.DynamicAABBTreeCollisionManager()
        manager.registerObjects([co1, co2, co3])
        manager.setup()

        return manager

    def test_register_and_unregisterObject(self):
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])))
        co2 = fcl.CollisionObject(fcl.Sphere(2), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))
        co3 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,5,0])))

        manager = fcl.DynamicAABBTreeCollisionManager()
        manager.registerObjects([co1, co2, co3])
        manager.setup()

        sphere_object = fcl.CollisionObject(fcl.Sphere(0.5), fcl.Transform(np.array([0,0,0,1]), np.array([0,2,0])))
        cdata = fcl.CollisionData()
        manager.collide(sphere_object, cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == True)

        ddata = fcl.DistanceData()
        manager.distance(sphere_object, ddata, fcl.defaultDistanceCallback)
        self.assertTrue(ddata.result.min_distance < 0)

        # After removing co2 from manager, sphere_object will not collide with manager
        manager.unregisterObject(co2)
        # @TODO: It seems that update is not needed after register/unregister object(s).
        manager.update()
        
        cdata = fcl.CollisionData()
        manager.collide(sphere_object, cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == False)
        
        # sphere_object's distance to co1 is 0.5m.
        ddata = fcl.DistanceData()
        manager.distance(sphere_object, ddata, fcl.defaultDistanceCallback)
        np.testing.assert_allclose(ddata.result.min_distance, 0.5, rtol=5*1e-6, atol=0)

        # Let's add co2 back to manager, so that sphere_object collides with it
        manager.registerObject(co2)
        cdata = fcl.CollisionData()
        manager.collide(sphere_object, cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == True)

        ddata = fcl.DistanceData()
        manager.distance(sphere_object, ddata, fcl.defaultDistanceCallback)
        self.assertTrue(ddata.result.min_distance < 0)

    def test_clear_and_empty_and_size(self):
        manager = self.construct_manager()

        self.assertTrue(manager.size() == 3)
        self.assertTrue(manager.empty() == False)

        manager.clear()
        self.assertTrue(manager.size() == 0)
        self.assertTrue(manager.empty() == True)

    def test_self_collision(self):
        manager = self.construct_manager()

        cdata = fcl.CollisionData()
        manager.collide(cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == True)

    def test_one2many_collision(self):
        manager = self.construct_manager()

        sphere_object1 = fcl.CollisionObject(fcl.Sphere(0.51), fcl.Transform(np.array([0,0,0,1]), np.array([0,1.5,0])))
        sphere_object2 = fcl.CollisionObject(fcl.Sphere(0.49), fcl.Transform(np.array([0,0,0,1]), np.array([0,1.5,0])))

        cdata = fcl.CollisionData()
        manager.collide(sphere_object1, cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == True)

        cdata = fcl.CollisionData()
        manager.collide(sphere_object2, cdata, fcl.defaultCollisionCallback)
        self.assertTrue(cdata.result.is_collision == False)


    def test_self_distance(self):
        # @TODO: use a helper function to assemble manager
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])))
        co2 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))
        
        manager = fcl.DynamicAABBTreeCollisionManager()
        manager.registerObjects([co1, co2])
        manager.setup()

        ddata = fcl.DistanceData()
        manager.distance(ddata, fcl.defaultDistanceCallback)
        np.testing.assert_allclose(ddata.result.min_distance, 2.5)

    def test_one2many_distance(self):
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])))
        co2 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))
        
        manager1 = fcl.DynamicAABBTreeCollisionManager()
        manager1.registerObjects([co1, co2])
        manager1.setup()

        sphere_object = fcl.CollisionObject(fcl.Sphere(0.5), fcl.Transform(np.array([0,0,0,1]), np.array([0,2,0])))

        ddata = fcl.DistanceData()
        manager1.distance(sphere_object, ddata, fcl.defaultDistanceCallback)
        np.testing.assert_allclose(ddata.result.min_distance, 0.5)

    def test_many2many_distance(self):
        co1 = fcl.CollisionObject(fcl.Sphere(1), fcl.Transform(np.array([0,0,0,1]), np.array([0,0,0])))
        co2 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,0])))
        manager1 = fcl.DynamicAABBTreeCollisionManager()
        manager1.registerObjects([co1, co2])
        manager1.setup()

        co3 = fcl.CollisionObject(fcl.Sphere(0.5), fcl.Transform(np.array([0,0,0,1]), np.array([0,2,0])))
        co4 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([0,0,0,1]), np.array([0,4,10])))
        manager2 = fcl.DynamicAABBTreeCollisionManager()
        manager2.registerObjects([co3, co4])
        manager2.setup()

        ddata = fcl.DistanceData()
        manager1.distance(manager2, ddata, fcl.defaultDistanceCallback)
        np.testing.assert_allclose(ddata.result.min_distance, 0.5)


if __name__ == '__main__':
    unittest.main()