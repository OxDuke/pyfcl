from libcpp cimport bool
# from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stdlib cimport free
# from libc.string cimport memcpy
import inspect

from cython.operator cimport dereference as deref#, preincrement as inc, address
# cimport numpy as np
import numpy
# ctypedef np.float64_t DOUBLE_t

cimport fcl_defs as defs
# cimport octomap_defs as octomap 
# cimport std_defs as std 
from collision_data import Contact, CostSource, CollisionRequest, ContinuousCollisionRequest, CollisionResult, ContinuousCollisionResult, DistanceRequest, DistanceResult
# from collision_data import Contact, CostSource, CollisionRequest, ContinuousCollisionRequest, CollisionResult, ContinuousCollisionResult, DistanceRequest, DistanceResult

# @TODO: This is a hack import, remove this one and import in __init__.py
from collision_data import CollisionData, DistanceData

from fcl_defs cimport Scalar

cimport eigen_wrappers as ew

cdef class Vector3:
    cdef defs.Vector3[Scalar] c_vector3
    
    #@TODO: Do we need explicit type in function parameters?
    def __cinit__(self, Scalar x, Scalar y, Scalar z):
        self.c_vector3 = defs.Vector3[Scalar](x, y, z)

    @property
    def x(self):
        return self.c_vector3[0]

    @x.setter
    def x(self, Scalar x):
        self.c_vector3[0] = x

    @property
    def y(self):
        return self.c_vector3[1]

    @y.setter
    def y(self, y):
        self.c_vector3[1] = y

    @property
    def z(self):
        return self.c_vector3[2]

    @z.setter
    def z(self, z):
        self.c_vector3[2] = <Scalar?> z

    def __getitem__(self, size_t key):
        return self.c_vector3[key]

    def __setitem__(self, size_t key, Scalar value):
        self.c_vector3[key] = value

cdef class Quaternion:
    cdef defs.Quaternion[Scalar]* thisptr
    def __cinit__(self, Scalar w, Scalar x, Scalar y, Scalar z):
        self.thisptr = new defs.Quaternion[Scalar](w, x, y, z)

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    @property
    def w(self):
        return (<defs.Quaternion[Scalar]*>self.thisptr).w()
   
    #@TODO: The test was successful
    # @w.setter
    # def w(self, value):
    #     ew.QuaternionSetw[Scalar](deref(self.thisptr), <Scalar?> value)

    @property
    def x(self):
        return (<defs.Quaternion[Scalar]*>self.thisptr).x()

    @property
    def y(self):
        return (<defs.Quaternion[Scalar]*>self.thisptr).y()

    @property
    def z(self):
        return (<defs.Quaternion[Scalar]*>self.thisptr).z()

cdef class Matrix3:
    cdef defs.Matrix3[Scalar] *thisptr

    def __cinit__(self):
        self.thisptr = new defs.Matrix3[Scalar]()

    def __getitem__(self, size_t key):
        return deref(self.thisptr)(key)

    def __setitem__(self, size_t key, Scalar value):
        ew.Matrix3SetValue[Scalar](deref(self.thisptr), key, value)

#@TODO: This class has problems, need to be re-implemented
cdef class Transform:
    cdef defs.Transform3[Scalar] *thisptr

    def __cinit__(self, *args):
        if len(args) == 0:
            self.thisptr = new defs.Transform3[Scalar]()
            ew.Transform3SetIdentity[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr))
        elif len(args) == 1:
            if isinstance(args[0], Transform):
                self.thisptr = new defs.Transform3[Scalar](deref((<Transform> args[0]).thisptr))
            else:
                data = numpy.array(args[0])
                if data.shape == (3,3):
                    #self.thisptr = new defs.Transform3[Scalar](numpy_to_mat3f(data))
                    self.thisptr = new defs.Transform3[Scalar]()
                    #@TODO: Make this faster by directly passing components
                    ew.Transform3FromMatrix3[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr), numpy_to_matrix3(data))
                elif data.shape == (4,):
                    #@TODO: Make this faster by directly passing components
                    self.thisptr = new defs.Transform3[Scalar]()
                    ew.Transform3FromQuaternion[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr), numpy_to_quaternion(data))
                elif data.shape == (3,):
                    #self.thisptr = new defs.Transform3[Scalar](numpy_to_vec3f(data))
                    self.thisptr = new defs.Transform3[Scalar]()
                    ew.Transform3FromVector3Numbers[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr), <Scalar?> data[0], <Scalar?> data[1], <Scalar?> data[2])
                else:
                    raise ValueError('Invalid input to Transform().')
        elif len(args) == 2:
            rot = numpy.array(args[0])
            trans = numpy.array(args[1]).squeeze()
            if not trans.shape == (3,):
                raise ValueError('Translation must be (3,).')

            if rot.shape == (3,3):
                #@TODO: Make this faster by directly passing components
                self.thisptr = new defs.Transform3[Scalar]()
                ew.Transform3FromMatrix3Vector3[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr), numpy_to_matrix3(rot), numpy_to_vector3(trans))
                #self.thisptr = new defs.Transform3[Scalar](numpy_to_mat3f(rot), numpy_to_vec3f(trans))
            elif rot.shape == (4,):
                #@TODO: Make this faster by directly passing components
                self.thisptr = new defs.Transform3[Scalar]()
                ew.Transform3FromQuaternionVector3[Scalar](deref(<defs.Transform3[Scalar]*> self.thisptr), numpy_to_quaternion(rot), numpy_to_vector3(trans))
                #self.thisptr = new defs.Transform3[Scalar](numpy_to_quaternion3f(rot), numpy_to_vec3f(trans))
            
            else:
                raise ValueError('Invalid input to Transform().')
        else:
            raise ValueError('Too many arguments to Transform().')

    def __dealloc__(self):
        if self.thisptr:
            free(self.thisptr)

    @property
    def linear(self):
        lin = (<defs.Transform3[Scalar]*> self.thisptr).linear()
        mat = Matrix3()
        # @TODO: Make sure that lin is in column major, mat is row major
        mat[0] = lin(0)
        mat[1] = lin(3)
        mat[2] = lin(6)
        mat[3] = lin(1)
        mat[4] = lin(4)
        mat[5] = lin(7)
        mat[6] = lin(2)
        mat[7] = lin(5)
        mat[8] = lin(8)
        
        return mat
    
    @linear.setter
    def linear(self, value):
        ew.Transform3SetLinear[Scalar](deref(self.thisptr), 
            value[0,0], value[0,1], value[0,2],
            value[1,0], value[1,1], value[1,1],
            value[2,0], value[2,1], value[2,2])
    
    @property
    def translation(self):
        trans = (<defs.Transform3[Scalar]*> self.thisptr).translation()
        return Vector3(trans[0], trans[1], trans[2])

    @translation.setter
    def translation(self, value):
        # @TODO: This is a hack
        ew.Transform3SetTranslation[Scalar](deref(self.thisptr), value[0], value[1], value[2])

    def __getitem__(self, key):
        if isinstance(key, tuple) and len(key) == 2:
            
            # @INFO: According to my profile, having the below index guard
            # induces a ~50ns overhead. W/o guard, [] takes ~50ns, w/ guard,
            # [] takes ~100ns.
            # row, col = key[0]%4, key[1]%4
            # if row > 3 or col > 3:
            #     raise IndexError("too many indices for Transform")

            
            #@TODO: Is the <size_t?> conversion bad? or hard to maintain?
            #@TODO: Add index guard here: key[0] <= 3 and key[1] <= 3
            return deref(<defs.Transform3[Scalar]*> self.thisptr)(<size_t?> key[0], <size_t?> key[1])
        else:
            raise ReferenceError("Index must be a tuple of length 2. E.g., [1,1]")
            #return deref(<defs.Transform3[Scalar]*> self.thisptr)(<size_t?> key)
    
    def __setitem__(self, key, value):
        raise NotImplementedError

    def toarray(self):
        return numpy.array([[self[0,0], self[0,1], self[0,2], self[0,3]],
                         [self[1,0], self[1,1], self[1,2], self[1,3]],
                         [self[2,0], self[2,1], self[2,2], self[2,3]],
                         [self[3,0], self[3,1], self[3,2], self[3,3]]])


    # def __repr__(self):
    #     return "Rot:\n" + self.linear.__repr__

cdef class CollisionObject:
    cdef defs.CollisionObject[Scalar] *thisptr
    # @TODO: can we do defs.CollisionGeometry[Scalar]* geom?
    cdef defs.PyObject *geom
    # @TODO: _no_instance seems useless, and the class only works when it is set to False
    cdef bool _no_instance

    def __cinit__(self, CollisionGeometry geom=None, Transform tf=None, _no_instance=False):
        if geom is None:
            geom = CollisionGeometry()
        defs.Py_INCREF(<defs.PyObject*> geom)
        self.geom = <defs.PyObject*> geom
        self._no_instance = _no_instance
        if geom.getNodeType() is not None and not self._no_instance:
            if tf is not None:
                self.thisptr = new defs.CollisionObject[Scalar](defs.shared_ptr[defs.CollisionGeometry[Scalar]](geom.thisptr), deref(tf.thisptr))
            else:
                self.thisptr = new defs.CollisionObject[Scalar](defs.shared_ptr[defs.CollisionGeometry[Scalar]](geom.thisptr))
            self.thisptr.setUserData(<void*> self.geom) # Save the python geometry object for later retrieval
        else:
            if not self._no_instance:
                raise ValueError

    def __dealloc__(self):
        if self.thisptr and not self._no_instance:
            #@TODO: what's the difference between: del self.thisptr & free(self.thisptr)
            free(self.thisptr)
        defs.Py_DECREF(self.geom)

    def getObjectType(self):
        return self.thisptr.getObjectType()

    def getNodeType(self):
        return self.thisptr.getNodeType()

    def getTranslation(self):
        return vector3_to_numpy(self.thisptr.getTranslation())

    def setTranslation(self, vec):
        self.thisptr.setTranslation(numpy_to_vector3(vec))
        self.thisptr.computeAABB()

    def getRotation(self):
        return matrix3_to_numpy(self.thisptr.getRotation())

    def setRotation(self, mat):
        self.thisptr.setRotation(numpy_to_matrix3(mat))
        self.thisptr.computeAABB()

    def getQuatRotation(self):
        return quaternion_to_numpy(self.thisptr.getQuatRotation())

    def setQuatRotation(self, q):
        self.thisptr.setQuatRotation(numpy_to_quaternion(q))
        self.thisptr.computeAABB()

    def getTransform(self):
        tf = Transform()
        tf.linear = self.getRotation()
        #@TODO: remove numpy_to_vector3
        tf.translation = self.getTranslation()

        #@TODO: Make this a constructor
        return tf

    def setTransform(self, tf):
        #@TODO: If tf.linear is not a rotation matrix, the transform will not be correct
        self.thisptr.setTransform(deref((<Transform> tf).thisptr))
        self.thisptr.computeAABB()

    def isOccupied(self):
        return self.thisptr.isOccupied()

    def isFree(self):
        return self.thisptr.isFree()

    def isUncertain(self):
        return self.thisptr.isUncertain()        


# cdef class CollisionObject:
#     cdef defs.CollisionObject *thisptr
#     cdef defs.PyObject *geom
#     cdef bool _no_instance

#     def __cinit__(self, CollisionGeometry geom=None, Transform tf=None, _no_instance=False):
#         if geom is None:
#             geom = CollisionGeometry()
#         defs.Py_INCREF(<defs.PyObject*> geom)
#         self.geom = <defs.PyObject*> geom
#         self._no_instance = _no_instance
#         if geom.getNodeType() is not None and not self._no_instance:
#             if tf is not None:
#                 self.thisptr = new defs.CollisionObject(defs.shared_ptr[defs.CollisionGeometry](geom.thisptr), deref(tf.thisptr))
#             else:
#                 self.thisptr = new defs.CollisionObject(defs.shared_ptr[defs.CollisionGeometry](geom.thisptr))
#             self.thisptr.setUserData(<void*> self.geom) # Save the python geometry object for later retrieval
#         else:
#             if not self._no_instance:
#                 raise ValueError

#     def __dealloc__(self):
#         if self.thisptr and not self._no_instance:
#             free(self.thisptr)
#         defs.Py_DECREF(self.geom)

#     def getObjectType(self):
#         return self.thisptr.getObjectType()

#     def getNodeType(self):
#         return self.thisptr.getNodeType()

#     def getTranslation(self):
#         return vec3f_to_numpy(self.thisptr.getTranslation())

#     def setTranslation(self, vec):
#         self.thisptr.setTranslation(numpy_to_vec3f(vec))
#         self.thisptr.computeAABB()

#     def getRotation(self):
#         return mat3f_to_numpy(self.thisptr.getRotation())

#     def setRotation(self, mat):
#         self.thisptr.setRotation(numpy_to_mat3f(mat))
#         self.thisptr.computeAABB()

#     def getQuatRotation(self):
#         return quaternion3f_to_numpy(self.thisptr.getQuatRotation())

#     def setQuatRotation(self, q):
#         self.thisptr.setQuatRotation(numpy_to_quaternion3f(q))
#         self.thisptr.computeAABB()

#     def getTransform(self):
#         rot = self.getRotation()
#         trans = self.getTranslation()
#         return Transform(rot, trans)

#     def setTransform(self, tf):
#         self.thisptr.setTransform(deref((<Transform> tf).thisptr))
#         self.thisptr.computeAABB()

#     def isOccupied(self):
#         return self.thisptr.isOccupied()

#     def isFree(self):
#         return self.thisptr.isFree()

#     def isUncertain(self):
#         return self.thisptr.isUncertain()        



cdef class CollisionGeometry:
    cdef defs.CollisionGeometry[Scalar] *thisptr

    def __cinit__(self):
        pass

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    def getNodeType(self):
        if self.thisptr:
            return self.thisptr.getNodeType()
        else:
            return None

    def computeLocalAABB(self):
        if self.thisptr:
            self.thisptr.computeLocalAABB()
        else:
            return None

    @property
    def aabb_center(self):
        if self.thisptr:
            return vector3_to_numpy(self.thisptr.aabb_center)
        else:
            return None

    @aabb_center.setter
    def aabb_center(self, value):
        if self.thisptr:
            self.thisptr.aabb_center[0] = <Scalar?> value[0]
            self.thisptr.aabb_center[1] = <Scalar?> value[1]
            self.thisptr.aabb_center[2] = <Scalar?> value[2]
        else:
            raise ReferenceError

cdef class ShapeBase(CollisionGeometry):
    #cdef defs.ShapeBase[Scalar] *thisptr
    def __cinit__(self):
        pass

cdef class TriangleP(ShapeBase):
    def __cinit__(self, a, b, c):
        self.thisptr = new defs.TriangleP[Scalar](numpy_to_vector3(a), numpy_to_vector3(b), numpy_to_vector3(c))
    
    @property
    def a(self):
        return vector3_to_numpy((<defs.TriangleP[Scalar]*> self.thisptr).a)
    @a.setter
    def a(self, value):
        (<defs.TriangleP[Scalar]*> self.thisptr).a[0] = <Scalar?> value[0]
        (<defs.TriangleP[Scalar]*> self.thisptr).a[1] = <Scalar?> value[1]
        (<defs.TriangleP[Scalar]*> self.thisptr).a[2] = <Scalar?> value[2]

    @property
    def b(self):
        return vector3_to_numpy((<defs.TriangleP[Scalar]*> self.thisptr).b)
    @b.setter
    def b(self, value):
        (<defs.TriangleP[Scalar]*> self.thisptr).b[0] = <Scalar?> value[0]
        (<defs.TriangleP[Scalar]*> self.thisptr).b[1] = <Scalar?> value[1]
        (<defs.TriangleP[Scalar]*> self.thisptr).b[2] = <Scalar?> value[2]

    @property
    def c(self):
        return vector3_to_numpy((<defs.TriangleP[Scalar]*> self.thisptr).c)
    @c.setter
    def c(self, value):
        (<defs.TriangleP[Scalar]*> self.thisptr).c[0] = <Scalar?> value[0]
        (<defs.TriangleP[Scalar]*> self.thisptr).c[1] = <Scalar?> value[1]
        (<defs.TriangleP[Scalar]*> self.thisptr).c[2] = <Scalar?> value[2]

# cdef class Box(CollisionGeometry):
#     def __cinit__(self, x, y, z):
#         self.thisptr = new defs.Box(x, y, z)

#     property side:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.Box*> self.thisptr).side)
#         def __set__(self, value):
#             (<defs.Box*> self.thisptr).side[0] = <double?> value[0]
#             (<defs.Box*> self.thisptr).side[1] = <double?> value[1]
#             (<defs.Box*> self.thisptr).side[2] = <double?> value[2]

cdef class Box(ShapeBase):
    def __cinit__(self, x, y, z):
        self.thisptr = new defs.Box[Scalar](x, y, z)

    @property
    def side(self):
        return vector3_to_numpy((<defs.Box[Scalar]*> self.thisptr).side)

    @side.setter
    def side(self, value):
        (<defs.Box[Scalar]*> self.thisptr).side[0] = <Scalar?> value[0]
        (<defs.Box[Scalar]*> self.thisptr).side[1] = <Scalar?> value[1]
        (<defs.Box[Scalar]*> self.thisptr).side[2] = <Scalar?> value[2]

cdef class Sphere(ShapeBase):
    def __cinit__(self, radius):
        self.thisptr = new defs.Sphere[Scalar](<Scalar?> radius)

    @property
    def radius(self):
        return (<defs.Sphere[Scalar]*> self.thisptr).radius

    @radius.setter
    def radius(self, Scalar value):
        (<defs.Sphere[Scalar]*> self.thisptr).radius = value

cdef class Ellipsoid(ShapeBase):
    def __cinit__(self, a, b, c):
        self.thisptr = new defs.Ellipsoid[Scalar](<Scalar?> a, <Scalar?> b, <Scalar?> c)

    @property
    def radii(self):
        return vector3_to_numpy((<defs.Ellipsoid[Scalar]*> self.thisptr).radii)
    
    @radii.setter
    def radii(self, values):
        (<defs.Ellipsoid[Scalar]*> self.thisptr).radii = numpy_to_vector3(values)

cdef class Capsule(ShapeBase):
    def __cinit__(self, radius, lz):
        self.thisptr = new defs.Capsule[Scalar](<Scalar?> radius, <Scalar?> lz)

    @property
    def radius(self):
        return (<defs.Capsule[Scalar]*> self.thisptr).radius

    @radius.setter
    def radius(self, value):
        (<defs.Capsule[Scalar]*> self.thisptr).radius = <Scalar?> value
    
    @property
    def lz(self):
        return (<defs.Capsule[Scalar]*> self.thisptr).lz

    @lz.setter
    def lz(self, value):
        (<defs.Capsule[Scalar]*> self.thisptr).lz = <Scalar?> value

cdef class Cone(ShapeBase):
    def __cinit__(self, radius, lz):
        self.thisptr = new defs.Cone[Scalar](<Scalar?> radius, <Scalar?> lz)

    @property
    def radius(self):
        return (<defs.Cone[Scalar]*> self.thisptr).radius

    @radius.setter
    def radius(self, value):
        (<defs.Cone[Scalar]*> self.thisptr).radius = <Scalar?> value
    
    @property
    def lz(self):
        return (<defs.Cone[Scalar]*> self.thisptr).lz

    @lz.setter
    def lz(self, value):
        (<defs.Cone[Scalar]*> self.thisptr).lz = <Scalar?> value


cdef class Cylinder(ShapeBase):
    def __cinit__(self, radius, lz):
        self.thisptr = new defs.Cylinder[Scalar](<Scalar?> radius, <Scalar?> lz)

    @property
    def radius(self):
        return (<defs.Cylinder[Scalar]*> self.thisptr).radius

    @radius.setter
    def radius(self, value):
        (<defs.Cylinder[Scalar]*> self.thisptr).radius = <Scalar?> value
    
    @property
    def lz(self):
        return (<defs.Cylinder[Scalar]*> self.thisptr).lz

    @lz.setter
    def lz(self, value):
        (<defs.Cylinder[Scalar]*> self.thisptr).lz = <Scalar?> value

cdef class Halfspace(ShapeBase):
    def __cinit__(self, n, d):
        self.thisptr = new defs.Halfspace[Scalar](defs.Vector3[Scalar](<Scalar?> n[0],
                                                     <Scalar?> n[1],
                                                     <Scalar?> n[2]),
                                          <Scalar?> d)

    @property
    def n(self):
        return vector3_to_numpy((<defs.Halfspace[Scalar]*> self.thisptr).n)

    @n.setter
    def n(self, value):
        (<defs.Halfspace[Scalar]*> self.thisptr).n[0] = <Scalar?> value[0]
        (<defs.Halfspace[Scalar]*> self.thisptr).n[1] = <Scalar?> value[1]
        (<defs.Halfspace[Scalar]*> self.thisptr).n[2] = <Scalar?> value[2]

    @property
    def d(self):
        return (<defs.Halfspace[Scalar]*> self.thisptr).d

    @d.setter
    def d(self, value):
        (<defs.Halfspace[Scalar]*> self.thisptr).d = <Scalar?> value

cdef class Plane(ShapeBase):
    def __cinit__(self, n, d):
        self.thisptr = new defs.Plane[Scalar](defs.Vector3[Scalar](<Scalar?> n[0],
                                                 <Scalar?> n[1],
                                                 <Scalar?> n[2]),
                                      <Scalar?> d)

    @property 
    def n(self):
        return vector3_to_numpy((<defs.Plane[Scalar]*> self.thisptr).n)
    
    @n.setter
    def n(self, value):
        (<defs.Plane[Scalar]*> self.thisptr).n[0] = <Scalar?> value[0]
        (<defs.Plane[Scalar]*> self.thisptr).n[1] = <Scalar?> value[1]
        (<defs.Plane[Scalar]*> self.thisptr).n[2] = <Scalar?> value[2]

    @property
    def d(self):
        return (<defs.Plane[Scalar]*> self.thisptr).d

    @d.setter
    def d(self, value):
        (<defs.Plane[Scalar]*> self.thisptr).d = <Scalar?> value

cdef class BVHModel(CollisionGeometry):
    def __cinit__(self):
        # @TODO: the pointer conversion is a hack,
        # I have no idea why you cannot directly assign it
        self.thisptr = <defs.CollisionGeometry[Scalar]*?> new defs.BVHModel[defs.OBBRSS[Scalar]]()

    def num_tries_(self):
        return (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).num_tris

    def buildState(self):
        return (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).build_state
    
    # @TODO: remove trailing underscore: num_tris_
    def beginModel(self, num_tris_=0, num_vertices_=0):
        n = (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).beginModel(<int?> num_tris_, <int?> num_vertices_)
        return n

    def endModel(self):
        n = (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).endModel()
        return n

#     def addVertex(self, x, y, z):
#         n = (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).addVertex(defs.Vec3f(<double?> x, <double?> y, <double?> z))
#         return self._check_ret_value(n)

#     def addTriangle(self, v1, v2, v3):
#         n = (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).addTriangle(numpy_to_vec3f(v1),
#                                                         numpy_to_vec3f(v2),
#                                                         numpy_to_vec3f(v3))
#         return self._check_ret_value(n)

    def addSubModel(self, verts, triangles):
        cdef vector[defs.Vector3[Scalar]] ps
        cdef vector[defs.Triangle] tris
        for vert in verts:
            ps.push_back(defs.Vector3[Scalar](<Scalar?> vert[0], <Scalar?> vert[1], <Scalar?> vert[2]))
        for tri in triangles:
            tris.push_back(defs.Triangle(<size_t?> tri[0], <size_t?> tri[1], <size_t?> tri[2]))
        # @TODO: Type casting is a mess here
        n = (<defs.BVHModel[defs.OBBRSS[Scalar]]*> self.thisptr).addSubModel(<vector[defs.Vector3[defs.BV_S]]?>ps, tris)
        return self._check_ret_value(n)

    def _check_ret_value(self, n):
        # @TODO: The correct way might be: defs.BVHReturnCode.BVH_OK
        if n == defs.BVH_OK:
            return True
        elif n == defs.BVH_ERR_MODEL_OUT_OF_MEMORY:
            raise MemoryError("Cannot allocate memory for vertices and triangles")
        elif n == defs.BVH_ERR_BUILD_OUT_OF_SEQUENCE:
            raise ValueError("BVH construction does not follow correct sequence")
        elif n == defs.BVH_ERR_BUILD_EMPTY_MODEL:
            raise ValueError("BVH geometry is not prepared")
        elif n == defs.BVH_ERR_BUILD_EMPTY_PREVIOUS_FRAME:
            raise ValueError("BVH geometry in previous frame is not prepared")
        elif n == defs.BVH_ERR_UNSUPPORTED_FUNCTION:
            raise ValueError("BVH funtion is not supported")
        elif n == defs.BVH_ERR_UNUPDATED_MODEL:
            raise ValueError("BVH model update failed")
        elif n == defs.BVH_ERR_INCORRECT_DATA:
            raise ValueError("BVH data is not valid")
        elif n == defs.BVH_ERR_UNKNOWN:
            raise ValueError("Unknown failure")
        else:
            return False


cdef quaternion_to_numpy(defs.Quaternion[Scalar] q):
    return numpy.array([q.w(), q.x(), q.y(), q.z()])

cdef defs.Quaternion[Scalar] numpy_to_quaternion(a):
    return defs.Quaternion[Scalar](<Scalar?> a[0], <Scalar?> a[1], <Scalar?> a[2], <Scalar?> a[3])

cdef vector3_to_numpy(defs.Vector3[Scalar] vec):
    return numpy.array([vec[0], vec[1], vec[2]])

cdef defs.Vector3[Scalar] numpy_to_vector3(a):
    return defs.Vector3[Scalar](<Scalar?> a[0], <Scalar?> a[1], <Scalar?> a[2])

cdef matrix3_to_numpy(defs.Matrix3[Scalar] m):
    return numpy.array([[m(0), m(1), m(2)],
                        [m(3), m(4), m(5)],
                        [m(6), m(7), m(8)]])

cdef defs.Matrix3[Scalar] numpy_to_matrix3(a):
    return ew.Matrix3FromNumbers[Scalar](<Scalar?> a[0][0], <Scalar?> a[0][1], <Scalar?> a[0][2],
                                 <Scalar?> a[1][0], <Scalar?> a[1][1], <Scalar?> a[1][2],
                                 <Scalar?> a[2][0], <Scalar?> a[2][1], <Scalar?> a[2][2])

# @TODO: defs.const_CollisionGeometry seems the same as defs.CollisionGeomtry
# I have moved from defs.const_CollisionGeometry to const defs.CollisionGeometry
# @TODO: WHy need this function at all? It is just a converter, why need if geom == <defs.const_ ... at all?
cdef c_to_python_collision_geometry(const defs.CollisionGeometry[Scalar]*geom, CollisionObject o1, CollisionObject o2):
    cdef CollisionGeometry o1_py_geom = <CollisionGeometry> ((<defs.CollisionObject[Scalar]*> o1.thisptr).getUserData())
    cdef CollisionGeometry o2_py_geom = <CollisionGeometry> ((<defs.CollisionObject[Scalar]*> o2.thisptr).getUserData())
    if geom == <const defs.CollisionGeometry[Scalar]*> o1_py_geom.thisptr:
        return o1_py_geom
    else:
        return o2_py_geom

cdef c_to_python_contact(defs.Contact[Scalar] contact, CollisionObject o1, CollisionObject o2):
    c = Contact()
    c.o1 = c_to_python_collision_geometry(contact.o1, o1, o2)
    c.o2 = c_to_python_collision_geometry(contact.o2, o1, o2)
    c.b1 = contact.b1
    c.b2 = contact.b2
    c.normal = vector3_to_numpy(contact.normal)
    c.pos = vector3_to_numpy(contact.pos)
    c.penetration_depth = contact.penetration_depth
    return c

cdef c_to_python_costsource(defs.CostSource[Scalar] cost_source):
    c = CostSource()
    c.aabb_min = vector3_to_numpy(cost_source.aabb_min)
    c.aabb_max = vector3_to_numpy(cost_source.aabb_max)
    c.cost_density = cost_source.cost_density
    c.total_cost = cost_source.total_cost
    return c

cdef copy_ptr_collision_object(defs.CollisionObject[Scalar]* cobj):
    geom = <CollisionGeometry> cobj.getUserData()
    co = CollisionObject(geom, _no_instance=True)
    (<CollisionObject> co).thisptr = cobj
    return co


cdef class DynamicAABBTreeCollisionManager:
    cdef defs.DynamicAABBTreeCollisionManager[Scalar] *thisptr
    cdef list objs

    def __cinit__(self):
        self.thisptr = new defs.DynamicAABBTreeCollisionManager[Scalar]()
        self.objs = []

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    def registerObjects(self, other_objs):
        cdef vector[defs.CollisionObjectPointer] pobjs
        for obj in other_objs:
            self.objs.append(obj)
            pobjs.push_back(<defs.CollisionObjectPointer?>(<CollisionObject[Scalar]?> obj).thisptr)
        self.thisptr.registerObjects(pobjs)

    def registerObject(self, obj):
        self.objs.append(obj)
        self.thisptr.registerObject((<CollisionObject[Scalar]?> obj).thisptr)

    def unregisterObject(self, obj):
        if obj in self.objs:
            self.objs.remove(obj)
            self.thisptr.unregisterObject((<CollisionObject[Scalar]?> obj).thisptr)

    def setup(self):
        self.thisptr.setup()

    def update(self, arg=None):
        cdef vector[defs.CollisionObjectPointer] objs
        if hasattr(arg, "__len__"):
            for a in arg:
                objs.push_back(<defs.CollisionObjectPointer?> (<CollisionObject[Scalar]?> a).thisptr)
            self.thisptr.update(objs)
        elif arg is None:
            self.thisptr.update()
        else:
            self.thisptr.update((<CollisionObject[Scalar]?> arg).thisptr)

    def getObjects(self):
        return list(self.objs)

    def collide(self, *args):
        if len(args) == 2 and inspect.isroutine(args[1]):
            fn = CollisionFunction(args[1], args[0])
            self.thisptr.collide(<void*> fn, <defs.CollisionCallBack?> CollisionCallBack)
        elif len(args) == 3 and isinstance(args[0], DynamicAABBTreeCollisionManager):
            fn = CollisionFunction(args[2], args[1])
            self.thisptr.collide((<DynamicAABBTreeCollisionManager?> args[0]).thisptr, <void*> fn, <defs.CollisionCallBack?> CollisionCallBack)
        elif len(args) == 3 and inspect.isroutine(args[2]):
            fn = CollisionFunction(args[2], args[1])
            self.thisptr.collide((<CollisionObject?> args[0]).thisptr, <void*> fn, <defs.CollisionCallBack?> CollisionCallBack)
        else:
            raise ValueError

    def distance(self, *args):
        if len(args) == 2 and inspect.isroutine(args[1]):
            fn = DistanceFunction(args[1], args[0])
            self.thisptr.distance(<void*> fn, <defs.DistanceCallBack?> DistanceCallBack)
        elif len(args) == 3 and isinstance(args[0], DynamicAABBTreeCollisionManager):
            fn = DistanceFunction(args[2], args[1])
            self.thisptr.distance((<DynamicAABBTreeCollisionManager?> args[0]).thisptr, <void*> fn, <defs.DistanceCallBack?> DistanceCallBack)
        elif len(args) == 3 and inspect.isroutine(args[2]):
            fn = DistanceFunction(args[2], args[1])
            self.thisptr.distance((<CollisionObject?> args[0]).thisptr, <void*> fn, <defs.DistanceCallBack?> DistanceCallBack)
        else:
            raise ValueError

    def clear(self):
        self.thisptr.clear()

    def empty(self):
        return self.thisptr.empty()

    def size(self):
        return self.thisptr.size()

#     property max_tree_nonbalanced_level:
#         def __get__(self):
#             return self.thisptr.max_tree_nonbalanced_level
#         def __set__(self, value):
#             self.thisptr.max_tree_nonbalanced_level = <int?> value

#     property tree_incremental_balance_pass:
#         def __get__(self):
#             return self.thisptr.tree_incremental_balance_pass
#         def __set__(self, value):
#             self.thisptr.tree_incremental_balance_pass = <int?> value

#     property tree_topdown_balance_threshold:
#         def __get__(self):
#             return self.thisptr.tree_topdown_balance_threshold
#         def __set__(self, value):
#             self.thisptr.tree_topdown_balance_threshold = <int?> value

#     property tree_topdown_level:
#         def __get__(self):
#             return self.thisptr.tree_topdown_level
#         def __set__(self, value):
#             self.thisptr.tree_topdown_level = <int?> value

#     property tree_init_level:
#         def __get__(self):
#             return self.thisptr.tree_init_level
#         def __set__(self, value):
#             self.thisptr.tree_init_level = <int?> value

#     property octree_as_geometry_collide:
#         def __get__(self):
#             return self.thisptr.octree_as_geometry_collide
#         def __set__(self, value):
#             self.thisptr.octree_as_geometry_collide = <bool?> value

#     property octree_as_geometry_distance:
#         def __get__(self):
#             return self.thisptr.octree_as_geometry_distance
#         def __set__(self, value):
#             self.thisptr.octree_as_geometry_distance = <bool?> value


def collide(CollisionObject o1, CollisionObject o2,
            request=None, result=None):

    if request is None:
        request = CollisionRequest()
    if result is None:
        result = CollisionResult()

    cdef defs.CollisionResult[Scalar] cresult
    
    # @TODO: Do we need [Scalar] here in defs.collide[Scalar] ?
    cdef size_t ret = defs.collide[Scalar](o1.thisptr, o2.thisptr,
                                   defs.CollisionRequest[Scalar](
                                       <size_t?> request.num_max_contacts,
                                       <bool?> request.enable_contact,
                                       <size_t?> request.num_max_cost_sources,
                                       <bool> request.enable_cost,
                                       <bool> request.use_approximate_cost,
                                       <defs.GJKSolverType?> request.gjk_solver_type
                                   ),
                                   cresult)

    result.is_collision = result.is_collision or cresult.isCollision()

    cdef vector[defs.Contact[Scalar]] contacts
    cresult.getContacts(contacts)
    for idx in range(contacts.size()):
        result.contacts.append(c_to_python_contact(contacts[idx], o1, o2))

    cdef vector[defs.CostSource[Scalar]] costs
    cresult.getCostSources(costs)
    for idx in range(costs.size()):
        result.cost_sources.append(c_to_python_costsource(costs[idx]))

    return ret

def continuousCollide(CollisionObject o1, Transform tf1_end,
                      CollisionObject o2, Transform tf2_end,
                      request = None, result = None):

    if request is None:
        request = ContinuousCollisionRequest()
    if result is None:
        result = ContinuousCollisionResult()

    cdef defs.ContinuousCollisionResult[Scalar] cresult

    cdef defs.Scalar ret = defs.continuousCollide[Scalar](o1.thisptr, deref(tf1_end.thisptr),
                                                    o2.thisptr, deref(tf2_end.thisptr),
                                                    defs.ContinuousCollisionRequest[Scalar](
                                                        <size_t?>             request.num_max_iterations,
                                                        <defs.Scalar?>      request.toc_err,
                                                        <defs.CCDMotionType?> request.ccd_motion_type,
                                                        <defs.GJKSolverType?> request.gjk_solver_type,
                                                        <defs.CCDSolverType?> request.ccd_solver_type,

                                                    ),
                                                    cresult)

    result.is_collide = result.is_collide or cresult.is_collide
    result.time_of_contact = min(cresult.time_of_contact, result.time_of_contact)
    return ret

# def continuousCollide(CollisionObject o1, Transform tf1_end,
#                       CollisionObject o2, Transform tf2_end,
#                       request = None, result = None):

#     if request is None:
#         request = ContinuousCollisionRequest()
#     if result is None:
#         result = ContinuousCollisionResult()

#     cdef defs.ContinuousCollisionResult cresult

#     cdef defs.FCL_REAL ret = defs.continuousCollide(o1.thisptr, deref(tf1_end.thisptr),
#                                                     o2.thisptr, deref(tf2_end.thisptr),
#                                                     defs.ContinuousCollisionRequest(
#                                                         <size_t?>             request.num_max_iterations,
#                                                         <defs.FCL_REAL?>      request.toc_err,
#                                                         <defs.CCDMotionType?> request.ccd_motion_type,
#                                                         <defs.GJKSolverType?> request.gjk_solver_type,
#                                                         <defs.CCDSolverType?> request.ccd_solver_type,

#                                                     ),
#                                                     cresult)

#     result.is_collide = result.is_collide or cresult.is_collide
#     result.time_of_contact = min(cresult.time_of_contact, result.time_of_contact)
#     return ret

def distance(CollisionObject o1, CollisionObject o2,
             request = None, result=None):

    if request is None:
        request = DistanceRequest()
    if result is None:
        result = DistanceResult()

    cdef defs.DistanceResult[Scalar] cresult

    cdef double dis = defs.distance[Scalar](o1.thisptr, o2.thisptr,
                                    defs.DistanceRequest[Scalar](
                                        <bool?> request.enable_nearest_points,
                                        <defs.GJKSolverType?> request.gjk_solver_type
                                    ),
                                    cresult)

    result.min_distance = min(cresult.min_distance, result.min_distance)
    # @TODO: No need to return nearest points if not enabled.
    result.nearest_points = [vector3_to_numpy(cresult.nearest_points[0]),
                             vector3_to_numpy(cresult.nearest_points[1])]
    result.o1 = c_to_python_collision_geometry(cresult.o1, o1, o2)
    result.o2 = c_to_python_collision_geometry(cresult.o2, o1, o2)
    result.b1 = cresult.b1
    result.b2 = cresult.b2
    return dis

def defaultCollisionCallback(CollisionObject o1, CollisionObject o2, cdata):
    request = cdata.request
    result = cdata.result

    if cdata.done:
        return True

    collide(o1, o2, request, result)

    if (not request.enable_cost and result.is_collision and len(result.contacts) > request.num_max_contacts):
        cdata.done = True

    return cdata.done

def defaultDistanceCallback(CollisionObject o1, CollisionObject o2, cdata):
    request = cdata.request
    result = cdata.result

    if cdata.done:
        return True, result.min_distance

    distance(o1, o2, request, result)

    dist = result.min_distance

    if dist <= 0:
        return True, dist

    return cdata.done, dist

# @TODO: Not sure what's going on inside this function:
cdef class CollisionFunction:
    cdef:
        object py_func
        object py_args

    def __init__(self, py_func, py_args):
        self.py_func = py_func
        self.py_args = py_args

    cdef bool eval_func(self, defs.CollisionObject[Scalar]* o1, defs.CollisionObject[Scalar]* o2):
        cdef object py_r = defs.PyObject_CallObject(self.py_func,
                                                    (copy_ptr_collision_object(o1),
                                                     copy_ptr_collision_object(o2),
                                                     self.py_args))
        return <bool?> py_r

# @TODO: Not sure what's going on inside this function:
cdef class DistanceFunction:
    cdef:
        object py_func
        object py_args

    def __init__(self, py_func, py_args):
        self.py_func = py_func
        self.py_args = py_args

    cdef bool eval_func(self, defs.CollisionObject[Scalar]* o1, defs.CollisionObject[Scalar]* o2, Scalar& dist):
        cdef object py_r = defs.PyObject_CallObject(self.py_func,
                                                    (copy_ptr_collision_object(o1),
                                                     copy_ptr_collision_object(o2),
                                                     self.py_args))
        (&dist)[0] = <Scalar?> py_r[1]
        return <bool?> py_r[0]

cdef inline bool CollisionCallBack(defs.CollisionObject[Scalar]* o1, defs.CollisionObject[Scalar]* o2, void* cdata):
    return (<CollisionFunction> cdata).eval_func(o1, o2)

cdef inline bool DistanceCallBack(defs.CollisionObject[Scalar]* o1, defs.CollisionObject[Scalar]* o2, void* cdata, Scalar& dist):
    return (<DistanceFunction> cdata).eval_func(o1, o2, dist)



#####################
# Below are copied 
######################
# # cython: language_level=2
# from libcpp cimport bool
# from libcpp.string cimport string
# from libcpp.vector cimport vector
# from libc.stdlib cimport free
# from libc.string cimport memcpy
# import inspect

# from cython.operator cimport dereference as deref, preincrement as inc, address
# cimport numpy as np
# import numpy
# ctypedef np.float64_t DOUBLE_t

# cimport fcl_defs as defs
# cimport octomap_defs as octomap 
# cimport std_defs as std 
# from collision_data import Contact, CostSource, CollisionRequest, ContinuousCollisionRequest, CollisionResult, ContinuousCollisionResult, DistanceRequest, DistanceResult

# ###############################################################################
# # Transforms
# ###############################################################################
# cdef class Transform:
#     cdef defs.Transform3f *thisptr

#     def __cinit__(self, *args):
#         if len(args) == 0:
#             self.thisptr = new defs.Transform3f()
#         elif len(args) == 1:
#             if isinstance(args[0], Transform):
#                 self.thisptr = new defs.Transform3f(deref((<Transform> args[0]).thisptr))
#             else:
#                 data = numpy.array(args[0])
#                 if data.shape == (3,3):
#                     self.thisptr = new defs.Transform3f(numpy_to_mat3f(data))
#                 elif data.shape == (4,):
#                     self.thisptr = new defs.Transform3f(numpy_to_quaternion3f(data))
#                 elif data.shape == (3,):
#                     self.thisptr = new defs.Transform3f(numpy_to_vec3f(data))
#                 else:
#                     raise ValueError('Invalid input to Transform().')
#         elif len(args) == 2:
#             rot = numpy.array(args[0])
#             trans = numpy.array(args[1]).squeeze()
#             if not trans.shape == (3,):
#                 raise ValueError('Translation must be (3,).')

#             if rot.shape == (3,3):
#                 self.thisptr = new defs.Transform3f(numpy_to_mat3f(rot), numpy_to_vec3f(trans))
#             elif rot.shape == (4,):
#                 self.thisptr = new defs.Transform3f(numpy_to_quaternion3f(rot), numpy_to_vec3f(trans))
#             else:
#                 raise ValueError('Invalid input to Transform().')
#         else:
#             raise ValueError('Too many arguments to Transform().')

#     def __dealloc__(self):
#         if self.thisptr:
#             free(self.thisptr)

#     def getRotation(self):
#         return mat3f_to_numpy(self.thisptr.getRotation())

#     def getTranslation(self):
#         return vec3f_to_numpy(self.thisptr.getTranslation())

#     def getQuatRotation(self):
#         return quaternion3f_to_numpy(self.thisptr.getQuatRotation())

#     def setRotation(self, R):
#         self.thisptr.setRotation(numpy_to_mat3f(R))

#     def setTranslation(self, T):
#         self.thisptr.setTranslation(numpy_to_vec3f(T))

#     def setQuatRotation(self, q):
#         self.thisptr.setQuatRotation(numpy_to_quaternion3f(q))

# ###############################################################################
# # Collision objects and geometries
# ###############################################################################

# cdef class CollisionObject:
#     cdef defs.CollisionObject *thisptr
#     cdef defs.PyObject *geom
#     cdef bool _no_instance

#     def __cinit__(self, CollisionGeometry geom=None, Transform tf=None, _no_instance=False):
#         if geom is None:
#             geom = CollisionGeometry()
#         defs.Py_INCREF(<defs.PyObject*> geom)
#         self.geom = <defs.PyObject*> geom
#         self._no_instance = _no_instance
#         if geom.getNodeType() is not None and not self._no_instance:
#             if tf is not None:
#                 self.thisptr = new defs.CollisionObject(defs.shared_ptr[defs.CollisionGeometry](geom.thisptr), deref(tf.thisptr))
#             else:
#                 self.thisptr = new defs.CollisionObject(defs.shared_ptr[defs.CollisionGeometry](geom.thisptr))
#             self.thisptr.setUserData(<void*> self.geom) # Save the python geometry object for later retrieval
#         else:
#             if not self._no_instance:
#                 raise ValueError

#     def __dealloc__(self):
#         if self.thisptr and not self._no_instance:
#             free(self.thisptr)
#         defs.Py_DECREF(self.geom)

#     def getObjectType(self):
#         return self.thisptr.getObjectType()

#     def getNodeType(self):
#         return self.thisptr.getNodeType()

#     def getTranslation(self):
#         return vec3f_to_numpy(self.thisptr.getTranslation())

#     def setTranslation(self, vec):
#         self.thisptr.setTranslation(numpy_to_vec3f(vec))
#         self.thisptr.computeAABB()

#     def getRotation(self):
#         return mat3f_to_numpy(self.thisptr.getRotation())

#     def setRotation(self, mat):
#         self.thisptr.setRotation(numpy_to_mat3f(mat))
#         self.thisptr.computeAABB()

#     def getQuatRotation(self):
#         return quaternion3f_to_numpy(self.thisptr.getQuatRotation())

#     def setQuatRotation(self, q):
#         self.thisptr.setQuatRotation(numpy_to_quaternion3f(q))
#         self.thisptr.computeAABB()

#     def getTransform(self):
#         rot = self.getRotation()
#         trans = self.getTranslation()
#         return Transform(rot, trans)

#     def setTransform(self, tf):
#         self.thisptr.setTransform(deref((<Transform> tf).thisptr))
#         self.thisptr.computeAABB()

#     def isOccupied(self):
#         return self.thisptr.isOccupied()

#     def isFree(self):
#         return self.thisptr.isFree()

#     def isUncertain(self):
#         return self.thisptr.isUncertain()

# cdef class CollisionGeometry:
#     cdef defs.CollisionGeometry *thisptr

#     def __cinit__(self):
#         pass

#     def __dealloc__(self):
#         if self.thisptr:
#             del self.thisptr

#     def getNodeType(self):
#         if self.thisptr:
#             return self.thisptr.getNodeType()
#         else:
#             return None

#     def computeLocalAABB(self):
#         if self.thisptr:
#             self.thisptr.computeLocalAABB()
#         else:
#             return None

#     property aabb_center:
#         def __get__(self):
#             if self.thisptr:
#                 return vec3f_to_numpy(self.thisptr.aabb_center)
#             else:
#                 return None
#         def __set__(self, value):
#             if self.thisptr:
#                 self.thisptr.aabb_center[0] = value[0]
#                 self.thisptr.aabb_center[1] = value[1]
#                 self.thisptr.aabb_center[2] = value[2]
#             else:
#                 raise ReferenceError

# cdef class TriangleP(CollisionGeometry):
#     def __cinit__(self, a, b, c):
#         self.thisptr = new defs.TriangleP(numpy_to_vec3f(a), numpy_to_vec3f(b), numpy_to_vec3f(c))

#     property a:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.TriangleP*> self.thisptr).a)
#         def __set__(self, value):
#             (<defs.TriangleP*> self.thisptr).a[0] = <double?> value[0]
#             (<defs.TriangleP*> self.thisptr).a[1] = <double?> value[1]
#             (<defs.TriangleP*> self.thisptr).a[2] = <double?> value[2]

#     property b:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.TriangleP*> self.thisptr).b)
#         def __set__(self, value):
#             (<defs.TriangleP*> self.thisptr).b[0] = <double?> value[0]
#             (<defs.TriangleP*> self.thisptr).b[1] = <double?> value[1]
#             (<defs.TriangleP*> self.thisptr).b[2] = <double?> value[2]

#     property c:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.TriangleP*> self.thisptr).c)
#         def __set__(self, value):
#             (<defs.TriangleP*> self.thisptr).c[0] = <double?> value[0]
#             (<defs.TriangleP*> self.thisptr).c[1] = <double?> value[1]
#             (<defs.TriangleP*> self.thisptr).c[2] = <double?> value[2]

# cdef class Box(CollisionGeometry):
#     def __cinit__(self, x, y, z):
#         self.thisptr = new defs.Box(x, y, z)

#     property side:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.Box*> self.thisptr).side)
#         def __set__(self, value):
#             (<defs.Box*> self.thisptr).side[0] = <double?> value[0]
#             (<defs.Box*> self.thisptr).side[1] = <double?> value[1]
#             (<defs.Box*> self.thisptr).side[2] = <double?> value[2]

# cdef class Sphere(CollisionGeometry):
#     def __cinit__(self, radius):
#         self.thisptr = new defs.Sphere(radius)

#     property radius:
#         def __get__(self):
#             return (<defs.Sphere*> self.thisptr).radius
#         def __set__(self, value):
#             (<defs.Sphere*> self.thisptr).radius = <double?> value

# cdef class Ellipsoid(CollisionGeometry):
#     def __cinit__(self, a, b, c):
#         self.thisptr = new defs.Ellipsoid(<double?> a, <double?> b, <double?> c)

#     property radii:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.Ellipsoid*> self.thisptr).radii)
#         def __set__(self, values):
#             (<defs.Ellipsoid*> self.thisptr).radii = numpy_to_vec3f(values)

# cdef class Capsule(CollisionGeometry):
#     def __cinit__(self, radius, lz):
#         self.thisptr = new defs.Capsule(radius, lz)

#     property radius:
#         def __get__(self):
#             return (<defs.Capsule*> self.thisptr).radius
#         def __set__(self, value):
#             (<defs.Capsule*> self.thisptr).radius = <double?> value

#     property lz:
#         def __get__(self):
#             return (<defs.Capsule*> self.thisptr).lz
#         def __set__(self, value):
#             (<defs.Capsule*> self.thisptr).lz = <double?> value

# cdef class Cone(CollisionGeometry):
#     def __cinit__(self, radius, lz):
#         self.thisptr = new defs.Cone(radius, lz)

#     property radius:
#         def __get__(self):
#             return (<defs.Cone*> self.thisptr).radius
#         def __set__(self, value):
#             (<defs.Cone*> self.thisptr).radius = <double?> value

#     property lz:
#         def __get__(self):
#             return (<defs.Cone*> self.thisptr).lz
#         def __set__(self, value):
#             (<defs.Cone*> self.thisptr).lz = <double?> value

# cdef class Cylinder(CollisionGeometry):
#     def __cinit__(self, radius, lz):
#         self.thisptr = new defs.Cylinder(radius, lz)

#     property radius:
#         def __get__(self):
#             return (<defs.Cylinder*> self.thisptr).radius
#         def __set__(self, value):
#             (<defs.Cylinder*> self.thisptr).radius = <double?> value

#     property lz:
#         def __get__(self):
#             return (<defs.Cylinder*> self.thisptr).lz
#         def __set__(self, value):
#             (<defs.Cylinder*> self.thisptr).lz = <double?> value

# cdef class Halfspace(CollisionGeometry):
#     def __cinit__(self, n, d):
#         self.thisptr = new defs.Halfspace(defs.Vec3f(<double?> n[0],
#                                                      <double?> n[1],
#                                                      <double?> n[2]),
#                                           <double?> d)

#     property n:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.Halfspace*> self.thisptr).n)
#         def __set__(self, value):
#             (<defs.Halfspace*> self.thisptr).n[0] = <double?> value[0]
#             (<defs.Halfspace*> self.thisptr).n[1] = <double?> value[1]
#             (<defs.Halfspace*> self.thisptr).n[2] = <double?> value[2]

#     property d:
#         def __get__(self):
#             return (<defs.Halfspace*> self.thisptr).d
#         def __set__(self, value):
#             (<defs.Halfspace*> self.thisptr).d = <double?> value

# cdef class Plane(CollisionGeometry):
#     def __cinit__(self, n, d):
#         self.thisptr = new defs.Plane(defs.Vec3f(<double?> n[0],
#                                                  <double?> n[1],
#                                                  <double?> n[2]),
#                                       <double?> d)

#     property n:
#         def __get__(self):
#             return vec3f_to_numpy((<defs.Plane*> self.thisptr).n)
#         def __set__(self, value):
#             (<defs.Plane*> self.thisptr).n[0] = <double?> value[0]
#             (<defs.Plane*> self.thisptr).n[1] = <double?> value[1]
#             (<defs.Plane*> self.thisptr).n[2] = <double?> value[2]

#     property d:
#         def __get__(self):
#             return (<defs.Plane*> self.thisptr).d
#         def __set__(self, value):
#             (<defs.Plane*> self.thisptr).d = <double?> value

# cdef class BVHModel(CollisionGeometry):
#     def __cinit__(self):
#         self.thisptr = new defs.BVHModel()

#     def num_tries_(self):
#         return (<defs.BVHModel*> self.thisptr).num_tris

#     def buildState(self):
#         return (<defs.BVHModel*> self.thisptr).build_state

#     def beginModel(self, num_tris_=0, num_vertices_=0):
#         n = (<defs.BVHModel*> self.thisptr).beginModel(<int?> num_tris_, <int?> num_vertices_)
#         return n

#     def endModel(self):
#         n = (<defs.BVHModel*> self.thisptr).endModel()
#         return n

#     def addVertex(self, x, y, z):
#         n = (<defs.BVHModel*> self.thisptr).addVertex(defs.Vec3f(<double?> x, <double?> y, <double?> z))
#         return self._check_ret_value(n)

#     def addTriangle(self, v1, v2, v3):
#         n = (<defs.BVHModel*> self.thisptr).addTriangle(numpy_to_vec3f(v1),
#                                                         numpy_to_vec3f(v2),
#                                                         numpy_to_vec3f(v3))
#         return self._check_ret_value(n)

#     def addSubModel(self, verts, triangles):
#         cdef vector[defs.Vec3f] ps
#         cdef vector[defs.Triangle] tris
#         for vert in verts:
#             ps.push_back(numpy_to_vec3f(vert))
#         for tri in triangles:
#             tris.push_back(defs.Triangle(<size_t?> tri[0], <size_t?> tri[1], <size_t?> tri[2]))
#         n = (<defs.BVHModel*> self.thisptr).addSubModel(ps, tris)
#         return self._check_ret_value(n)

#     def _check_ret_value(self, n):
#         if n == defs.BVH_OK:
#             return True
#         elif n == defs.BVH_ERR_MODEL_OUT_OF_MEMORY:
#             raise MemoryError("Cannot allocate memory for vertices and triangles")
#         elif n == defs.BVH_ERR_BUILD_OUT_OF_SEQUENCE:
#             raise ValueError("BVH construction does not follow correct sequence")
#         elif n == defs.BVH_ERR_BUILD_EMPTY_MODEL:
#             raise ValueError("BVH geometry is not prepared")
#         elif n == defs.BVH_ERR_BUILD_EMPTY_PREVIOUS_FRAME:
#             raise ValueError("BVH geometry in previous frame is not prepared")
#         elif n == defs.BVH_ERR_UNSUPPORTED_FUNCTION:
#             raise ValueError("BVH funtion is not supported")
#         elif n == defs.BVH_ERR_UNUPDATED_MODEL:
#             raise ValueError("BVH model update failed")
#         elif n == defs.BVH_ERR_INCORRECT_DATA:
#             raise ValueError("BVH data is not valid")
#         elif n == defs.BVH_ERR_UNKNOWN:
#             raise ValueError("Unknown failure")
#         else:
#             return False

# cdef class OcTree(CollisionGeometry):
#     cdef octomap.OcTree* tree

#     def __cinit__(self, r, data):
#         cdef std.stringstream ss
#         cdef vector[char] vd = data
#         ss.write(vd.data(), len(data))

#         self.tree = new octomap.OcTree(r) 
#         self.tree.readBinaryData(ss)
#         self.thisptr = new defs.OcTree(defs.shared_ptr[octomap.OcTree](self.tree))


# ###############################################################################
# # Collision managers
# ###############################################################################

# cdef class DynamicAABBTreeCollisionManager:
#     cdef defs.DynamicAABBTreeCollisionManager *thisptr
#     cdef list objs

#     def __cinit__(self):
#         self.thisptr = new defs.DynamicAABBTreeCollisionManager()
#         self.objs = []

#     def __dealloc__(self):
#         if self.thisptr:
#             del self.thisptr

#     def registerObjects(self, other_objs):
#         cdef vector[defs.CollisionObject*] pobjs
#         for obj in other_objs:
#             self.objs.append(obj)
#             pobjs.push_back((<CollisionObject?> obj).thisptr)
#         self.thisptr.registerObjects(pobjs)

#     def registerObject(self, obj):
#         self.objs.append(obj)
#         self.thisptr.registerObject((<CollisionObject?> obj).thisptr)

#     def unregisterObject(self, obj):
#         if obj in self.objs:
#             self.objs.remove(obj)
#             self.thisptr.unregisterObject((<CollisionObject?> obj).thisptr)

#     def setup(self):
#         self.thisptr.setup()

#     def update(self, arg=None):
#         cdef vector[defs.CollisionObject*] objs
#         if hasattr(arg, "__len__"):
#             for a in arg:
#                 objs.push_back((<CollisionObject?> a).thisptr)
#             self.thisptr.update(objs)
#         elif arg is None:
#             self.thisptr.update()
#         else:
#             self.thisptr.update((<CollisionObject?> arg).thisptr)

#     def getObjects(self):
#         return list(self.objs)

#     def collide(self, *args):
#         if len(args) == 2 and inspect.isroutine(args[1]):
#             fn = CollisionFunction(args[1], args[0])
#             self.thisptr.collide(<void*> fn, CollisionCallBack)
#         elif len(args) == 3 and isinstance(args[0], DynamicAABBTreeCollisionManager):
#             fn = CollisionFunction(args[2], args[1])
#             self.thisptr.collide((<DynamicAABBTreeCollisionManager?> args[0]).thisptr, <void*> fn, CollisionCallBack)
#         elif len(args) == 3 and inspect.isroutine(args[2]):
#             fn = CollisionFunction(args[2], args[1])
#             self.thisptr.collide((<CollisionObject?> args[0]).thisptr, <void*> fn, CollisionCallBack)
#         else:
#             raise ValueError

#     def distance(self, *args):
#         if len(args) == 2 and inspect.isroutine(args[1]):
#             fn = DistanceFunction(args[1], args[0])
#             self.thisptr.distance(<void*> fn, DistanceCallBack)
#         elif len(args) == 3 and isinstance(args[0], DynamicAABBTreeCollisionManager):
#             fn = DistanceFunction(args[2], args[1])
#             self.thisptr.distance((<DynamicAABBTreeCollisionManager?> args[0]).thisptr, <void*> fn, DistanceCallBack)
#         elif len(args) == 3 and inspect.isroutine(args[2]):
#             fn = DistanceFunction(args[2], args[1])
#             self.thisptr.distance((<CollisionObject?> args[0]).thisptr, <void*> fn, DistanceCallBack)
#         else:
#             raise ValueError

#     def clear(self):
#         self.thisptr.clear()

#     def empty(self):
#         return self.thisptr.empty()

#     def size(self):
#         return self.thisptr.size()

#     property max_tree_nonbalanced_level:
#         def __get__(self):
#             return self.thisptr.max_tree_nonbalanced_level
#         def __set__(self, value):
#             self.thisptr.max_tree_nonbalanced_level = <int?> value

#     property tree_incremental_balance_pass:
#         def __get__(self):
#             return self.thisptr.tree_incremental_balance_pass
#         def __set__(self, value):
#             self.thisptr.tree_incremental_balance_pass = <int?> value

#     property tree_topdown_balance_threshold:
#         def __get__(self):
#             return self.thisptr.tree_topdown_balance_threshold
#         def __set__(self, value):
#             self.thisptr.tree_topdown_balance_threshold = <int?> value

#     property tree_topdown_level:
#         def __get__(self):
#             return self.thisptr.tree_topdown_level
#         def __set__(self, value):
#             self.thisptr.tree_topdown_level = <int?> value

#     property tree_init_level:
#         def __get__(self):
#             return self.thisptr.tree_init_level
#         def __set__(self, value):
#             self.thisptr.tree_init_level = <int?> value

#     property octree_as_geometry_collide:
#         def __get__(self):
#             return self.thisptr.octree_as_geometry_collide
#         def __set__(self, value):
#             self.thisptr.octree_as_geometry_collide = <bool?> value

#     property octree_as_geometry_distance:
#         def __get__(self):
#             return self.thisptr.octree_as_geometry_distance
#         def __set__(self, value):
#             self.thisptr.octree_as_geometry_distance = <bool?> value

# ###############################################################################
# # Collision and distance functions
# ###############################################################################

# def collide(CollisionObject o1, CollisionObject o2,
#             request=None, result=None):

#     if request is None:
#         request = CollisionRequest()
#     if result is None:
#         result = CollisionResult()

#     cdef defs.CollisionResult cresult

#     cdef size_t ret = defs.collide(o1.thisptr, o2.thisptr,
#                                    defs.CollisionRequest(
#                                        <size_t?> request.num_max_contacts,
#                                        <bool?> request.enable_contact,
#                                        <size_t?> request.num_max_cost_sources,
#                                        <bool> request.enable_cost,
#                                        <bool> request.use_approximate_cost,
#                                        <defs.GJKSolverType?> request.gjk_solver_type
#                                    ),
#                                    cresult)

#     result.is_collision = result.is_collision or cresult.isCollision()

#     cdef vector[defs.Contact] contacts
#     cresult.getContacts(contacts)
#     for idx in range(contacts.size()):
#         result.contacts.append(c_to_python_contact(contacts[idx], o1, o2))

#     cdef vector[defs.CostSource] costs
#     cresult.getCostSources(costs)
#     for idx in range(costs.size()):
#         result.cost_sources.append(c_to_python_costsource(costs[idx]))

#     return ret

# def continuousCollide(CollisionObject o1, Transform tf1_end,
#                       CollisionObject o2, Transform tf2_end,
#                       request = None, result = None):

#     if request is None:
#         request = ContinuousCollisionRequest()
#     if result is None:
#         result = ContinuousCollisionResult()

#     cdef defs.ContinuousCollisionResult cresult

#     cdef defs.FCL_REAL ret = defs.continuousCollide(o1.thisptr, deref(tf1_end.thisptr),
#                                                     o2.thisptr, deref(tf2_end.thisptr),
#                                                     defs.ContinuousCollisionRequest(
#                                                         <size_t?>             request.num_max_iterations,
#                                                         <defs.FCL_REAL?>      request.toc_err,
#                                                         <defs.CCDMotionType?> request.ccd_motion_type,
#                                                         <defs.GJKSolverType?> request.gjk_solver_type,
#                                                         <defs.CCDSolverType?> request.ccd_solver_type,

#                                                     ),
#                                                     cresult)

#     result.is_collide = result.is_collide or cresult.is_collide
#     result.time_of_contact = min(cresult.time_of_contact, result.time_of_contact)
#     return ret

# def distance(CollisionObject o1, CollisionObject o2,
#              request = None, result=None):

#     if request is None:
#         request = DistanceRequest()
#     if result is None:
#         result = DistanceResult()

#     cdef defs.DistanceResult cresult

#     cdef double dis = defs.distance(o1.thisptr, o2.thisptr,
#                                     defs.DistanceRequest(
#                                         <bool?> request.enable_nearest_points,
#                                         <defs.GJKSolverType?> request.gjk_solver_type
#                                     ),
#                                     cresult)

#     result.min_distance = min(cresult.min_distance, result.min_distance)
#     result.nearest_points = [vec3f_to_numpy(cresult.nearest_points[0]),
#                              vec3f_to_numpy(cresult.nearest_points[1])]
#     result.o1 = c_to_python_collision_geometry(cresult.o1, o1, o2)
#     result.o2 = c_to_python_collision_geometry(cresult.o2, o1, o2)
#     result.b1 = cresult.b1
#     result.b2 = cresult.b2
#     return dis

# ###############################################################################
# # Collision and Distance Callback Functions
# ###############################################################################

# def defaultCollisionCallback(CollisionObject o1, CollisionObject o2, cdata):
#     request = cdata.request
#     result = cdata.result

#     if cdata.done:
#         return True

#     collide(o1, o2, request, result)

#     if (not request.enable_cost and result.is_collision and len(result.contacts) > request.num_max_contacts):
#         cdata.done = True

#     return cdata.done

# def defaultDistanceCallback(CollisionObject o1, CollisionObject o2, cdata):
#     request = cdata.request
#     result = cdata.result

#     if cdata.done:
#         return True, result.min_distance

#     distance(o1, o2, request, result)

#     dist = result.min_distance

#     if dist <= 0:
#         return True, dist

#     return cdata.done, dist

# cdef class CollisionFunction:
#     cdef:
#         object py_func
#         object py_args

#     def __init__(self, py_func, py_args):
#         self.py_func = py_func
#         self.py_args = py_args

#     cdef bool eval_func(self, defs.CollisionObject*o1, defs.CollisionObject*o2):
#         cdef object py_r = defs.PyObject_CallObject(self.py_func,
#                                                     (copy_ptr_collision_object(o1),
#                                                      copy_ptr_collision_object(o2),
#                                                      self.py_args))
#         return <bool?> py_r

# cdef class DistanceFunction:
#     cdef:
#         object py_func
#         object py_args

#     def __init__(self, py_func, py_args):
#         self.py_func = py_func
#         self.py_args = py_args

#     cdef bool eval_func(self, defs.CollisionObject*o1, defs.CollisionObject*o2, defs.FCL_REAL& dist):
#         cdef object py_r = defs.PyObject_CallObject(self.py_func,
#                                                     (copy_ptr_collision_object(o1),
#                                                      copy_ptr_collision_object(o2),
#                                                      self.py_args))
#         (&dist)[0] = <defs.FCL_REAL?> py_r[1]
#         return <bool?> py_r[0]

# cdef inline bool CollisionCallBack(defs.CollisionObject*o1, defs.CollisionObject*o2, void*cdata):
#     return (<CollisionFunction> cdata).eval_func(o1, o2)

# cdef inline bool DistanceCallBack(defs.CollisionObject*o1, defs.CollisionObject*o2, void*cdata, defs.FCL_REAL& dist):
#     return (<DistanceFunction> cdata).eval_func(o1, o2, dist)


# ###############################################################################
# # Helper Functions
# ###############################################################################

# cdef quaternion3f_to_numpy(defs.Quaternion3f q):
#     return numpy.array([q.getW(), q.getX(), q.getY(), q.getZ()])

# cdef defs.Quaternion3f numpy_to_quaternion3f(a):
#     return defs.Quaternion3f(<double?> a[0], <double?> a[1], <double?> a[2], <double?> a[3])

# cdef vec3f_to_numpy(defs.Vec3f vec):
#     return numpy.array([vec[0], vec[1], vec[2]])

# cdef defs.Vec3f numpy_to_vec3f(a):
#     return defs.Vec3f(<double?> a[0], <double?> a[1], <double?> a[2])

# cdef mat3f_to_numpy(defs.Matrix3f m):
#     return numpy.array([[m(0,0), m(0,1), m(0,2)],
#                         [m(1,0), m(1,1), m(1,2)],
#                         [m(2,0), m(2,1), m(2,2)]])

# cdef defs.Matrix3f numpy_to_mat3f(a):
#     return defs.Matrix3f(<double?> a[0][0], <double?> a[0][1], <double?> a[0][2],
#                          <double?> a[1][0], <double?> a[1][1], <double?> a[1][2],
#                          <double?> a[2][0], <double?> a[2][1], <double?> a[2][2])

# cdef c_to_python_collision_geometry(defs.const_CollisionGeometry*geom, CollisionObject o1, CollisionObject o2):
#     cdef CollisionGeometry o1_py_geom = <CollisionGeometry> ((<defs.CollisionObject*> o1.thisptr).getUserData())
#     cdef CollisionGeometry o2_py_geom = <CollisionGeometry> ((<defs.CollisionObject*> o2.thisptr).getUserData())
#     if geom == <defs.const_CollisionGeometry*> o1_py_geom.thisptr:
#         return o1_py_geom
#     else:
#         return o2_py_geom

# cdef c_to_python_contact(defs.Contact contact, CollisionObject o1, CollisionObject o2):
#     c = Contact()
#     c.o1 = c_to_python_collision_geometry(contact.o1, o1, o2)
#     c.o2 = c_to_python_collision_geometry(contact.o2, o1, o2)
#     c.b1 = contact.b1
#     c.b2 = contact.b2
#     c.normal = vec3f_to_numpy(contact.normal)
#     c.pos = vec3f_to_numpy(contact.pos)
#     c.penetration_depth = contact.penetration_depth
#     return c

# cdef c_to_python_costsource(defs.CostSource cost_source):
#     c = CostSource()
#     c.aabb_min = vec3f_to_numpy(cost_source.aabb_min)
#     c.aabb_max = vec3f_to_numpy(cost_source.aabb_max)
#     c.cost_density = cost_source.cost_density
#     c.total_cost = cost_source.total_cost
#     return c

# cdef copy_ptr_collision_object(defs.CollisionObject*cobj):
#     geom = <CollisionGeometry> cobj.getUserData()
#     co = CollisionObject(geom, _no_instance=True)
#     (<CollisionObject> co).thisptr = cobj
#     return co
