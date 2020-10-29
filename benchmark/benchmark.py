#!/usr/bin/env python

# 3rd imports
import os
import timeit
import numpy as np

import trimesh

import pyfcl as fcl
#import fcl

def build_box_object():
    b = fcl.Box(1,1,1)
    tf = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0]))
    co = fcl.CollisionObject(b, tf)

def build_sphere_object():
    s = fcl.Sphere(2)
    tf = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0]))
    co = fcl.CollisionObject(s, tf)

def build_bvh_outof_trimesh(mesh):
    verts = np.array(mesh.vertices)
    tris = np.array(mesh.faces)

    bvh = fcl.BVHModel()
    bvh.beginModel(len(tris), len(verts))
    bvh.addSubModel(verts, tris)
    bvh.endModel()

    return bvh

def mesh_vs_convex():
    # vertices = np.array([[0,0,1],
    #           [0,0,0],
    #           [0,1,0],
    #           [1,0,0]])
    # faces = [[0,2,1],[0,1,3],[0,3,2],[1,2,3]]

    cvx_link = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm_cvx.stl'))
    vertices = cvx_link.vertices
    faces = cvx_link.faces
    
    nfaces = [len(face) for face in faces]
    cfaces = [[pair[0]] + pair[1] for pair in zip(nfaces,faces)]
    cfaces = [item for sublist in cfaces for item in sublist]

    if fcl.__package__ == "pyfcl":
        convex_repr = fcl.Convex(vertices, 4, cfaces)
    else:
        convex_repr = None

    mesh_repr = fcl.BVHModel()
    mesh_repr.beginModel(len(faces), len(vertices))
    mesh_repr.addSubModel(vertices, faces)
    mesh_repr.endModel()
    
    return convex_repr, mesh_repr

def do_collide(co1, co2):

    req = fcl.CollisionRequest()
    res = fcl.CollisionResult()

    ret = fcl.collide(co1, co2, req, res)

def do_distance(co1, co2):

    req = fcl.DistanceRequest()
    res = fcl.DistanceResult()

    ret = fcl.distance(co1, co2, req, res)

def show_mesh():
    import tf.transformations as tfm

    m1 = trimesh.load(os.path.join(os.path.dirname(__file__), 'complex_mesh.stl'))
    m2 = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))
    m2.apply_translation([0.75, 0, -0.15])

    (m1+m2).show()

if __name__ == '__main__':

    #show_mesh()


    mesh1 = trimesh.load(os.path.join(os.path.dirname(__file__), 'complex_mesh.stl'))
    bvh1 = build_bvh_outof_trimesh(mesh1)

    mesh2 = trimesh.load(os.path.join(os.path.dirname(__file__), 'ur5_forearm.stl'))
    bvh2 = build_bvh_outof_trimesh(mesh2)

    tf1 = fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0]))
    tf2 = fcl.Transform(np.array([1,0,0,0]), np.array([0.75, 0, -0.15]))

    co1 = fcl.CollisionObject(bvh1, tf1)
    co2 = fcl.CollisionObject(bvh2, tf2)


    # co1 = fcl.CollisionObject(fcl.Box(1,1,1), fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0])))
    # co2 = fcl.CollisionObject(fcl.Box(1,2,3), fcl.Transform(np.array([1,0,0,0]), np.array([0.999,0,0])))
    # co2 = fcl.CollisionObject(fcl.Ellipsoid(1, 0.8, 0.64), fcl.Transform(np.array([1,0,0,0]), np.array([0.999,0,0])))


    cocvx, cobvh = mesh_vs_convex()
    co1 = fcl.CollisionObject(bvh1, fcl.Transform(np.array([1,0,0,0]), np.array([0,0,0])))
    co2 = fcl.CollisionObject(cocvx, fcl.Transform(np.array([1,0,0,0]), np.array([0.75, 0, 0.55])))

    #co1 = fcl.CollisionObject(fcl.Cone(1, 0.5), fcl.Transform(np.array([1,0,0,0]), np.array([0,0,3])))
            

    # f = lambda : build_bvh_outof_trimesh(mesh)

    # print(timeit.timeit(f, number=10))

    g = lambda: do_collide(co1, co2)
    h = lambda: do_distance(co1, co2)

    print(timeit.timeit(g, number=10000))
    print(timeit.timeit(h, number=1000))
    #print(timeit.timeit(build_box_object, number=10000))

    
