#!/usr/bin/env python

import os
import timeit
import numpy as np

import trimesh

import fcl

from benchmark import build_bvh_outof_trimesh

def do_collide(co1, co2):
    req = fcl.CollisionRequest(num_max_contacts=1500, enable_contact=True)
    res = fcl.CollisionResult()
    ret = fcl.collide(co1, co2, req, res)

if __name__ == '__main__':
    mesh1 = trimesh.load(os.path.join(os.path.dirname(__file__), 'complex_mesh.stl'))
    bvh1 = build_bvh_outof_trimesh(mesh1)

    mesh2 = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))
    bvh2 = build_bvh_outof_trimesh(mesh2)

    tf1 = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0]))
    tf2 = fcl.Transform(np.array([1,0,0,0]), np.array([0.54, 0, -0.35]))

    co1 = fcl.CollisionObject(bvh1, tf1)
    co2 = fcl.CollisionObject(bvh2, tf2)

    f = lambda: do_collide(co1, co2)

    print(timeit.timeit(f, number=100))