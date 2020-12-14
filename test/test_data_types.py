from __future__ import print_function, division

import sys
import numpy as np
import unittest

import transformations as tfm

import fcl

from common_utils import double_float_difference


class TestTransform(unittest.TestCase):
    def generate_random_transform(self,
                                  identity_rotation=False,
                                  identity_translation=False):
        if identity_rotation:
            random_quaternion = np.array([0, 0, 0, 1])
        else:
            random_quaternion = tfm.random_quaternion()

        if identity_translation:
            random_translation = np.array([0, 0, 0])
        else:
            random_translation = tfm.random_vector(3)

        random_homogeneous_matrix = tfm.quaternion_matrix(random_quaternion)
        random_homogeneous_matrix[0:3, 3] = random_translation

        # FCL's quaternion format is [w,x,y,z], while tfm's is [x,y,z,w]
        # So we have to roll 1 position to the right.
        random_quaternion_wxyz = np.roll(random_quaternion, 1)

        return random_homogeneous_matrix, random_quaternion_wxyz, random_translation

    def is_transform_close(self, transform, ground_truth_transform):
        np.testing.assert_allclose(transform.toarray(),
                                   ground_truth_transform,
                                   rtol=0,
                                   atol=3 * sys.float_info.epsilon +
                                   double_float_difference)

    def test_default_constructor(self):
        tf = fcl.Transform()
        self.is_transform_close(tf, tfm.identity_matrix())

    def test_constructors(self):
        """
        We test the below constructors:
         - fcl.Transform()
         - fcl.Transform(fcl.Transform)
         - fcl.Transform(Quaternion, Vector3)
         - fcl.Transform(Matrix3, Vector3)
         - fcl.Transform(Quaternion)
         - fcl.Transform(Matrix3)
         - fcl.Transform(Vector3)
        """

        tf = fcl.Transform()
        self.is_transform_close(tf, tfm.identity_matrix())

        rmat, rq, rv = self.generate_random_transform()
        tf0 = fcl.Transform(rq, rv)
        tf = fcl.Transform(tf0)
        self.is_transform_close(tf, rmat)

        rmat, rq, rv = self.generate_random_transform()
        tf = fcl.Transform(rq, rv)
        self.is_transform_close(tf, rmat)

        rmat, rq, rv = self.generate_random_transform()
        tf = fcl.Transform(rmat[0:3, 0:3], rv)
        self.is_transform_close(tf, rmat)

        rmat, rq, _ = self.generate_random_transform(identity_translation=True)
        tf = fcl.Transform(rq)
        self.is_transform_close(tf, rmat)

        rmat, rq, _ = self.generate_random_transform(identity_translation=True)
        tf = fcl.Transform(rmat[0:3, 0:3])
        self.is_transform_close(tf, rmat)

        rmat, _, rv = self.generate_random_transform(identity_rotation=True)
        tf = fcl.Transform(rv)
        self.is_transform_close(tf, rmat)

    def test_copy_constructor(self):
        rmat, rq, rv = self.generate_random_transform()
        tf1 = fcl.Transform(rq, rv)
        tf2 = fcl.Transform(tf1)
        np.testing.assert_allclose(tf1.toarray(),
                                   tf2.toarray(),
                                   rtol=5 * 1e-6,
                                   atol=0)


class TestCollisionObject(unittest.TestCase):
    def generate_random_transform(self,
                                  identity_rotation=False,
                                  identity_translation=False):
        if identity_rotation:
            random_quaternion = np.array([0, 0, 0, 1])
        else:
            random_quaternion = tfm.random_quaternion()

        if identity_translation:
            random_translation = np.array([0, 0, 0])
        else:
            random_translation = tfm.random_vector(3)

        random_homogeneous_matrix = tfm.quaternion_matrix(random_quaternion)
        random_homogeneous_matrix[0:3, 3] = random_translation

        # FCL's quaternion format is [w,x,y,z], while tfm's is [x,y,z,w]
        # So we have to roll 1 position to the right.
        random_quaternion_wxyz = np.roll(random_quaternion, 1)

        return random_homogeneous_matrix, random_quaternion_wxyz, random_translation

    def check_transform(self, co, ground_truth_transform):
        np.testing.assert_allclose(co.getTranslation(),
                                   ground_truth_transform[0:3, 3],
                                   rtol=0,
                                   atol=0)
        np.testing.assert_allclose(co.getRotation(),
                                   ground_truth_transform[0:3, 0:3],
                                   rtol=0,
                                   atol=1e-14)
        np.testing.assert_allclose(tfm.quaternion_matrix(np.roll(co.getQuatRotation(),-1))[0:3, 0:3],
                                   ground_truth_transform[0:3, 0:3],
                                   rtol=0,
                                   atol=1e-14)
        np.testing.assert_allclose(co.getTransform(),
                                   ground_truth_transform,
                                   rtol=0,
                                   atol=1e-14)

    def test_set_transform(self):
        tmat, rq, rt = self.generate_random_transform()
        
        # @TODO: Use more geometries like box, cylinder...
        b = fcl.Sphere(1)
        tf = fcl.Transform(rq, rt)
        co = fcl.CollisionObject(b, tf)

        self.check_transform(co, tmat)
  
        _, _, rt = self.generate_random_transform()
        tmat[0:3, 3] = rt
        co.setTranslation(rt)
        self.check_transform(co, tmat)

        new_tmat, rq, _ = self.generate_random_transform()
        tmat[0:3, 0:3] = new_tmat[0:3, 0:3]
        co.setRotation(tmat[0:3, 0:3])
        self.check_transform(co, tmat)

        new_tmat, rq, _ = self.generate_random_transform()
        tmat[0:3, 0:3] = new_tmat[0:3, 0:3]
        co.setQuatRotation(rq)
        self.check_transform(co, tmat)

        tmat, rq, rt = self.generate_random_transform()
        co.setTransform(fcl.Transform(rq, rt))
        self.check_transform(co, tmat)

    def test_getCollisionGeometryId(self):
        b = fcl.Sphere(1)
        tf = fcl.Transform()
        co = fcl.CollisionObject(b, tf)

        self.assertTrue(id(b), co.getCollisionGeometryId())

    def test2(self):
        # Just make sure fcl.CollisionObject can be instantiated
        # when _no_instance = True
        co = fcl.CollisionObject(_no_instance=True)


if __name__ == '__main__':

    unittest.main()
