from __future__ import print_function, division

import sys
import numpy as np
import unittest

import transformations as tfm

import fcl

from common_utils import double_float_difference

class TestTransform(unittest.TestCase):

    def generate_random_transform(self, identity_rotation=False, identity_translation=False):
        if identity_rotation:
            random_quaternion = np.array([0,0,0,1])
        else:
            random_quaternion = tfm.random_quaternion()
        
        if identity_translation:
            random_translation = np.array([0,0,0])
        else:
            random_translation = tfm.random_vector(3)

        random_homogeneous_matrix = tfm.quaternion_matrix(random_quaternion)
        random_homogeneous_matrix[0:3,3] = random_translation
        
        # FCL's quaternion format is [w,x,y,z], while tfm's is [x,y,z,w]
        # So we have to roll 1 position to the right.
        random_quaternion_wxyz = np.roll(random_quaternion, 1)

        return random_homogeneous_matrix, random_quaternion_wxyz, random_translation

    def is_transform_close(self, transform, ground_truth_transform):
        np.testing.assert_allclose(transform.toarray(), ground_truth_transform, rtol=0, atol=3*sys.float_info.epsilon + double_float_difference)

    def test_default_constructor(self):
        tf = fcl.Transform()
        self.is_transform_close(tf, tfm.identity_matrix())

    def test_constructors(self):
        """
        We test the below constructors:
         - fcl.Transform(Quaternion, Vector3)
         - fcl.Transform(Matrix3, Vector3)
         - fcl.Transform(Quaternion)
         - fcl.Transform(Matrix3)
         - fcl.Transform(Vector3)
        """
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
        np.testing.assert_allclose(tf1.toarray(), tf2.toarray(), rtol=5*1e-6, atol=0)


    def test_linear_and_translation(self):
        # rmat, rq, rv = self.generate_random_transform()          
        # tf = fcl.Transform(rq, rv)
        # np.testing.assert_allclose(tf1.toarray(), tf2.toarray(), rtol=5*1e-6, atol=0)
        pass
        #raise NotImplementedError

class TestCollisionObject(unittest.TestCase):
    
    def hi(self):
        pass


if __name__ == '__main__':

    unittest.main()
    