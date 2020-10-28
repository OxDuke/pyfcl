#!/usr/bin/env python

# 3rd imports
import numpy as np
import trimesh

#import pyfcl as fcl
import fcl

def build_bvh_outof_trimesh(mesh):
	verts = np.array(mesh.vertices)
	tris = np.array(mesh.faces)

	bvh = fcl.BVHModel()
	bvh.beginModel(len(tris), len(verts))
	bvh.addSubModel(verts, tris)
	bvh.endModel()

	return bvh

if __name__ == '__main__':
	mesh = trimesh.load('./ur5_forearm.stl')

	build_bvh_outof_trimesh(mesh)