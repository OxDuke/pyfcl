cimport fcl_defs as defs

ctypedef float Scalar

def hello_fcl():
    print("Hello FCL!")

cdef class Vector3:
    cdef defs.Vector3[Scalar] c_vector3

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

    @property
    def z(self):
        return self.c_vector3[2]

    def __getitem__(self, size_t key):
        return self.c_vector3[key]

    def __setitem__(self, size_t key, Scalar value):
        self.c_vector3[key] = value


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

    # property aabb_center:
    #     def __get__(self):
    #         if self.thisptr:
    #             return vec3f_to_numpy(self.thisptr.aabb_center)
    #         else:
    #             return None
    #     def __set__(self, value):
    #         if self.thisptr:
    #             self.thisptr.aabb_center[0] = value[0]
    #             self.thisptr.aabb_center[1] = value[1]
    #             self.thisptr.aabb_center[2] = value[2]
    #         else:
    #             raise ReferenceError

cdef class ShapeBase:
    cdef defs.ShapeBase[Scalar] *thisptr

cdef class Sphere(ShapeBase):
    #cdef defs.Sphere[Scalar] c_sphere
    def __cinit__(self, Scalar radius):
        self.thisptr = new defs.Sphere[Scalar](radius)
        #self.c_sphere = Sphere[Scalar](radius)

    @property
    def radius(self):
        return (<defs.Sphere[Scalar]*> self.thisptr).radius
        #return self.c_sphere.radius

    @radius.setter
    def radius(self, Scalar value):
        (<defs.Sphere[Scalar]*> self.thisptr).radius = value
        #self.c_sphere.radius = value
