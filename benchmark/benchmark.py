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

def do_collide(co1, co2):

    req = fcl.CollisionRequest()
    res = fcl.CollisionResult()

    ret = fcl.collide(co1, co2, req, res)

def show_mesh():
    import tf.transformations as tfm

    m1 = trimesh.load(os.path.join(os.path.dirname(__file__), 'complex_mesh.stl'))
    m2 = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))
    m2.apply_translation([0.0, 0, 1])

    (m1+m2).show()

if __name__ == '__main__':
    mesh1 = trimesh.load(os.path.join(os.path.dirname(__file__), 'complex_mesh.stl'))
    bvh1 = build_bvh_outof_trimesh(mesh1)

    mesh2 = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))
    bvh2 = build_bvh_outof_trimesh(mesh2)

    tf1 = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0]))
    tf2 = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0.2]))

    co1 = fcl.CollisionObject(bvh1, tf1)
    co2 = fcl.CollisionObject(bvh2, tf2)

    # f = lambda : build_bvh_outof_trimesh(mesh)

    # print(timeit.timeit(f, number=10))

    g = lambda: do_collide(co1, co2)

    print(timeit.timeit(g, number=10000))

    #show_mesh()
