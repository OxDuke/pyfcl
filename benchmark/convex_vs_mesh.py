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
    #print(len(res.contacts))

def do_distance(co1, co2):

    req = fcl.DistanceRequest()
    res = fcl.DistanceResult()

    ret = fcl.distance(co1, co2, req, res)

def build_convex_outof_trimesh(convex_mesh):
    if not convex_mesh.is_convex:
        raise ValueError("mesh is not convex!")

    vertices = convex_mesh.vertices
    faces = convex_mesh.faces
    
    nfaces = [len(face) for face in faces]
    cfaces = [[pair[0]] + pair[1] for pair in zip(nfaces,faces)]
    cfaces = [item for sublist in cfaces for item in sublist]

    return fcl.Convex(vertices, len(faces), cfaces)



if __name__ == "__main__":
    cvx_mesh = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm_cvx.stl'))

    c1 = build_convex_outof_trimesh(cvx_mesh)
    b1 = build_bvh_outof_trimesh(cvx_mesh)

    co1 = fcl.CollisionObject(c1, fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0])))
    co2 = fcl.CollisionObject(b1, fcl.Transform(np.array([1,0,0,0]), np.array([0.05,0,0])))
    
    f = lambda: do_collide(co1, co2)

    f()

    print(timeit.timeit(f, number=1000))

