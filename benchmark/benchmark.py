#!/usr/bin/env python

# 3rd imports
import os
import timeit
import numpy as np

import trimesh

import pyfcl as fcl
#import fcl

def build_bvh_outof_trimesh(mesh):
	verts = np.array(mesh.vertices)
	tris = np.array(mesh.faces)

	bvh = fcl.BVHModel()
	bvh.beginModel(len(tris), len(verts))
	bvh.addSubModel(verts, tris)
	bvh.endModel()

	return bvh

if __name__ == '__main__':
	mesh = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))

	f = lambda : build_bvh_outof_trimesh(mesh)

	print(timeit.timeit(f, number=1000))

	
