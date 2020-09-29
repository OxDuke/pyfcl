#ctypedef float Scalar

cdef extern from "fcl/common/types.h" namespace "fcl":
    cdef cppclass Vector3[S]:
        Vector3() except +
        Vector3(S x, S y, S z) except +
        S& operator[](size_t i)

cdef extern from "fcl/geometry/collision_geometry.h" namespace "fcl":
    cdef enum OBJECT_TYPE:
        OT_UNKNOWN, OT_BVH, OT_GEOM, OT_OCTREE, OT_COUNT

    cdef enum NODE_TYPE:
        BV_UNKNOWN, BV_AABB, BV_OBB, BV_RSS, BV_kIOS, BV_OBBRSS, BV_KDOP16, BV_KDOP18, BV_KDOP24, GEOM_BOX, GEOM_SPHERE, GEOM_ELLIPSOID, GEOM_CAPSULE, GEOM_CONE, GEOM_CYLINDER, GEOM_CONVEX, GEOM_PLANE, GEOM_HALFSPACE, GEOM_TRIANGLE, GEOM_OCTREE, NODE_COUNT
    
    cdef cppclass CollisionGeometry[S]:
        CollisionGeometry() except + 
        OBJECT_TYPE getObjectType()
        NODE_TYPE getNodeType()
        void computeLocalAABB()
        Vector3[S] aabb_center
        S aabb_radius
        S cost_density
        S threshold_occupied
        S threshold_free

cdef extern from "fcl/geometry/shape/shape_base.h" namespace "fcl":
    cdef cppclass ShapeBase[S](CollisionGeometry[S]):
        ShapeBase() except +

cdef extern from "fcl/geometry/shape/sphere.h" namespace "fcl":
    cdef cppclass Sphere[S](ShapeBase[S]):
        Sphere(S radius_) except +
        S radius

cdef extern from "fcl/geometry/shape/convex.h" namespace 