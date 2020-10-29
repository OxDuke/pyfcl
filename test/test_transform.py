#!/usr/bin/env python

from __future__ import print_function, division

import numpy as np
import unittest

import transformations as tfm

import fcl

class TestTransform(unittest.TestCase):

    def check_tf(self, transform, ground_truth_tf):
        np.testing.assert_allclose(transform.toarray(), 
        	ground_truth_tf,
        	rtol=0, atol=0)

    def test_constructor1(self):
        tf = fcl.Transform()
        self.check_tf(tf, tfm.identity_matrix())

    def test_constructor1(self):
        tf = fcl.Transform()
        self.check_tf(tf, tfm.identity_matrix())