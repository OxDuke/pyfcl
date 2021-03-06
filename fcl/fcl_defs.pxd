#################################################
# Below are copied from python-fcl/fcl_defs.pxd #
#################################################

from libcpp cimport bool
# from libcpp.string cimport string
from libcpp.vector cimport vector
# from libcpp.set cimport set
from libcpp.memory cimport shared_ptr, make_shared
# cimport octomap_defs as octomap

ctypedef double Scalar
cdef cppclass BV_S "double"
# @TODO: This is a hack
# Because if you do vector[CollisionObject[S]*], cython will raise error:
# The error message is: Expected an identifier or literal
cdef cppclass CollisionObjectPointer "fcl::CollisionObject<double>*"

cdef cppclass CollisionCallBack "bool (*)(fcl::CollisionObject<double>* o1, fcl::CollisionObject<double>* o2, void* cdata)"
cdef cppclass DistanceCallBack "bool (*)(fcl::CollisionObject<double>* o1, fcl::CollisionObject<double>* o2, void* cdata, double& dist)"


# @TODO: This is for CollisionObject, I want to remove this
cdef extern from "Python.h":
       ctypedef struct PyObject
       void Py_INCREF(PyObject *obj)
       void Py_DECREF(PyObject *obj)
       object PyObject_CallObject(object obj, object args)
       object PySequence_Concat(object obj1, object obj2)


cdef extern from "fcl/common/types.h" namespace "fcl":
    cdef cppclass Vector3[S]:
        Vector3() except +
        Vector3(S x, S y, S z) except +

        S& operator[](size_t i)

    cdef cppclass Matrix3[S]:
        Matrix3() except +

        S& operator()(size_t i)         
        S& operator()(size_t i, size_t j)
    
    cdef cppclass Quaternion[S]:
        Quaternion() except +
        Quaternion(S w, S x, S y, S z) except +

        S& w()
        S& x()
        S& y()
        S& z()

    cdef cppclass Transform3[S]:
        Transform3() except + 
        Transform3(Transform3[S]& tf_)

        Matrix3[S]& linear()
        Vector3[S]& translation()
        S& operator()(size_t i)         
        S& operator()(size_t i, size_t j)


cdef extern from "fcl/narrowphase/continuous_collision_request.h" namespace "fcl":
    cdef enum CCDMotionType:
        CCDM_TRANS, CCDM_LINEAR, CCDM_SCREW, CCDM_SPLINE

    cdef enum CCDSolverType:
        CCDC_NAIVE, CCDC_CONSERVATIVE_ADVANCEMENT, CCDC_RAY_SHOOTING, CCDC_POLYNOMIAL_SOLVER


cdef extern from "fcl/narrowphase/gjk_solver_type.h" namespace "fcl":
    cdef enum GJKSolverType:
        GST_LIBCCD, GST_INDEP

cdef extern from "fcl/narrowphase/contact.h" namespace "fcl":
    cdef cppclass Contact[S]:
        CollisionGeometry[S] *o1
        CollisionGeometry[S] *o2
        int b1
        int b2
        Vector3[S] normal
        Vector3[S] pos
        S penetration_depth
        Contact() except +
        Contact(CollisionGeometry[S]* o1_,
                CollisionGeometry[S]* o2_,
                int b1_, int b2_) except +


cdef extern from "fcl/narrowphase/cost_source.h" namespace "fcl":
    cdef cppclass CostSource[S]:
        Vector3[S] aabb_min
        Vector3[S] aabb_max
        S cost_density
        S total_cost


cdef extern from "fcl/narrowphase/collision_result.h" namespace "fcl":
    cdef cppclass CollisionResult[S]:
        CollisionResult() except +
        bool isCollision()
        void getContacts(vector[Contact[S]]& contacts_)
        void getCostSources(vector[CostSource[S]]& cost_sources_)


cdef extern from "fcl/narrowphase/continuous_collision_result.h" namespace "fcl":
    cdef cppclass ContinuousCollisionResult[S]:
        ContinuousCollisionResult() except +
        bool is_collide
        S time_of_contact
        Transform3[S] contact_tf1, contact_tf2


cdef extern from "fcl/narrowphase/collision_request.h" namespace "fcl":
    cdef cppclass CollisionRequest[S]:
        size_t num_max_contacts
        bool enable_contact
        size_t num_max_cost_sources
        bool enable_cost
        bool use_approximate_cost
        GJKSolverType gjk_solver_type
        CollisionRequest(size_t num_max_contacts_,
                         bool enable_contact_,
                         size_t num_max_cost_sources_,
                         bool enable_cost_,
                         bool use_approximate_cost_,
                         GJKSolverType gjk_solver_type_)


cdef extern from "fcl/narrowphase/continuous_collision_request.h" namespace "fcl":
    cdef cppclass ContinuousCollisionRequest[S]:
        # @TODO: remove trailing underscore
        size_t num_max_iterations_,
        S toc_err_,
        CCDMotionType ccd_motion_type_,
        GJKSolverType gjk_solver_type_,
        GJKSolverType ccd_solver_type_

        ContinuousCollisionRequest(
                            size_t num_max_iterations_,
                            S toc_err_,
                            CCDMotionType ccd_motion_type_,
                            GJKSolverType gjk_solver_type_,
                            CCDSolverType ccd_solver_type_ )


cdef extern from "fcl/narrowphase/distance_result.h" namespace "fcl":
    cdef cppclass DistanceResult[S]:
        S min_distance
        Vector3[S]* nearest_points
        CollisionGeometry[S]* o1
        CollisionGeometry[S]* o2
        int b1
        int b2
        DistanceResult(S min_distance_) except +
        DistanceResult() except +

cdef extern from "fcl/narrowphase/distance_request.h" namespace "fcl":
    cdef cppclass DistanceRequest[S]:
        # @TODO: There are more parameters
        bool enable_nearest_points
        bool enable_signed_distance
        S rel_err
        S abs_err
        S distance_tolerance
        GJKSolverType gjk_solver_type
        # @TODO: Remove trailing underscore
        DistanceRequest(
            bool enable_nearest_points_, 
            bool enable_signed_distance_, 
            S rel_err_, 
            S abs_err_, 
            S distance_tolerance, 
            GJKSolverType gjk_solver_type_) except +


cdef extern from "fcl/geometry/collision_geometry.h" namespace "fcl":
    cdef enum OBJECT_TYPE:
        OT_UNKNOWN, OT_BVH, OT_GEOM, OT_OCTREE, OT_COUNT

    cdef enum NODE_TYPE:
        BV_UNKNOWN, BV_AABB, BV_OBB, BV_RSS, BV_kIOS, BV_OBBRSS, BV_KDOP16, BV_KDOP18, BV_KDOP24, 
        GEOM_BOX, GEOM_SPHERE, GEOM_ELLIPSOID, GEOM_CAPSULE, GEOM_CONE, GEOM_CYLINDER, GEOM_CONVEX, 
        GEOM_PLANE, GEOM_HALFSPACE, GEOM_TRIANGLE, GEOM_OCTREE, NODE_COUNT
  
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

cdef extern from "fcl/narrowphase/collision_object.h" namespace "fcl":
    cdef cppclass CollisionObject[S]:
        CollisionObject() except +
        CollisionObject(const shared_ptr[CollisionGeometry[S]]& cgeom_) except +
        CollisionObject(const shared_ptr[CollisionGeometry[S]]& cgeom_, Transform3[S]& tf) except +
        # @TODO: There is a  another constructor https://flexible-collision-library.github.io/de/d4f/collision__object_8h_source.html
        OBJECT_TYPE getObjectType()
        NODE_TYPE getNodeType()
        Vector3[S]& getTranslation()
        Matrix3[S]& getRotation()
        Quaternion[S]& getQuatRotation()
        Transform3[S]& getTransform()
        shared_ptr[CollisionGeometry[S]]& collisionGeometry()
        void setTranslation(const Vector3[S]& T)
        void setRotation(const Matrix3[S]& M)
        void setQuatRotation(const Quaternion[S]& q)
        void setTransform(const Quaternion[S]& q, const Vector3[S]& T)
        void setTransform(const Matrix3[S]& R, const Vector3[S]& T)
        void setTransform(const Transform3[S]& tf)
        void setUserData(void *data)
        void computeAABB()
        void *getUserData()
        bool isOccupied()
        bool isFree()
        bool isUncertain()
    
    # @TODO: What does the string inside the "" mean? Seems useless.
    # ctypedef CollisionGeometry const_CollisionGeometry "const fcl::CollisionGeometry"
    # ctypedef CollisionObject const_CollisionObject "const fcl::CollisionObject"


cdef extern from "fcl/geometry/shape/shape_base.h" namespace "fcl":
    cdef cppclass ShapeBase[S](CollisionGeometry[S]):
        ShapeBase() except +

cdef extern from "fcl/geometry/shape/triangle_p.h" namespace "fcl":
    cdef cppclass TriangleP[S](ShapeBase[S]):
        TriangleP(Vector3[S]& a_, Vector3[S]& b_, Vector3[S]& c_) except +
        Vector3[S] a, b, c

cdef extern from "fcl/geometry/shape/box.h" namespace "fcl":
    cdef cppclass Box[S](ShapeBase[S]):
        Box(S x, S y, S z) except +
        Vector3[S] side

cdef extern from "fcl/geometry/shape/sphere.h" namespace "fcl":
    cdef cppclass Sphere[S](ShapeBase[S]):
        Sphere(S radius_) except +
        S radius

cdef extern from "fcl/geometry/shape/sphere.h" namespace "fcl":
    cdef cppclass Ellipsoid[S](ShapeBase[S]):
        Ellipsoid(S a_, S b_, S c_) except +
        Vector3[S] radii

cdef extern from "fcl/geometry/shape/capsule.h" namespace "fcl":
    cdef cppclass Capsule[S](ShapeBase[S]):
        Capsule(S radius_, S lz_) except +
        S radius
        S lz

cdef extern from "fcl/geometry/shape/cone.h" namespace "fcl":
    cdef cppclass Cone[S](ShapeBase[S]):
        Cone(S radius_, S lz_) except +
        S radius
        S lz

cdef extern from "fcl/geometry/shape/cylinder.h" namespace "fcl":
    cdef cppclass Cylinder[S](ShapeBase[S]):
        Cylinder(S radius_, S lz_) except +
        S radius
        S lz

cdef extern from "fcl/geometry/shape/convex.h" namespace "fcl":
    cdef cppclass Convex[S](ShapeBase[S]):
        Convex(const shared_ptr[const vector[Vector3[S]]]& vertices, 
            int num_faces, 
            const shared_ptr[const vector[int]]& faces) except +

cdef extern from "fcl/geometry/shape/halfspace.h" namespace "fcl":
    cdef cppclass Halfspace[S](ShapeBase[S]):
        Halfspace(Vector3[S]& n_, S d_) except +
        Vector3[S] n
        S d

cdef extern from "fcl/geometry/shape/plane.h" namespace "fcl":
    cdef cppclass Plane[S](ShapeBase[S]):
        Plane(Vector3[S]& n_, S d_) except +
        Vector3[S] n
        S d


cdef extern from "fcl/broadphase/broadphase_dynamic_AABB_tree.h" namespace "fcl":
    
    cdef cppclass DynamicAABBTreeCollisionManager[S]:
        DynamicAABBTreeCollisionManager() except +
        void registerObjects(vector[CollisionObjectPointer]& other_objs)
        void registerObject(CollisionObject[S]* obj)
        void unregisterObject(CollisionObject[S]* obj)
        void collide(DynamicAABBTreeCollisionManager[S]* mgr, void* cdata, CollisionCallBack callback)
        void distance(DynamicAABBTreeCollisionManager[S]* mgr, void* cdata, DistanceCallBack callback)
        void collide(CollisionObject[S]* obj, void* cdata, CollisionCallBack callback)
        void distance(CollisionObject[S]* obj, void* cdata, DistanceCallBack callback)
        void collide(void* cdata, CollisionCallBack callback)
        void distance(void* cdata, DistanceCallBack callback)
        void setup()
        void update()
        void update(CollisionObject[S]* updated_obj)
        void update(vector[CollisionObjectPointer] updated_objs)
        void clear()
        bool empty()
        size_t size()
        int max_tree_nonbalanced_level
        int tree_incremental_balance_pass
        int& tree_topdown_balance_threshold
        int& tree_topdown_level
        int tree_init_level
        bool octree_as_geometry_collide
        bool octree_as_geometry_distance

cdef extern from "fcl/narrowphase/collision.h" namespace "fcl":
    size_t collide[S](CollisionObject[S]* o1, CollisionObject[S]* o2,
                   CollisionRequest[S]& request,
                   CollisionResult[S]& result)
    
    # # @TODO: This function seems never used
    # size_t collide[S](CollisionGeometry[S]* o1, Transform3[S]& tf1,
    #                CollisionGeometry[S]* o2, Transform3[S]& tf2,
    #                CollisionRequest[S]& request,
    #                CollisionResult[S]& result)

cdef extern from "fcl/narrowphase/continuous_collision.h" namespace "fcl":
    # S continuousCollide[S](CollisionGeometry[S]* o1, Transform3[S]& tf1_beg, Transform3[S]& tf1_end,
    #                            CollisionGeometry[S]* o2, Transform3[S]& tf2_beg, Transform3[S]& tf2_end,
    #                            ContinuousCollisionRequest[S]& request,
    #                            ContinuousCollisionResult[S]& result)

    S continuousCollide[S](CollisionObject[S]* o1, Transform3[S]& tf1_end,
                               CollisionObject[S]* o2, Transform3[S]& tf2_end,
                               ContinuousCollisionRequest[S]& request,
                               ContinuousCollisionResult[S]& result)


cdef extern from "fcl/narrowphase/distance.h" namespace "fcl":
    S distance[S](CollisionObject[S]* o1, CollisionObject[S]* o2,
                DistanceRequest[S]& request, DistanceResult[S]& result)
    
    # S distance[S](CollisionGeometry[S]* o1, Transform3[S]& tf1,
    #             CollisionGeometry[S]* o2, Transform3[S]& tf2,
    #             DistanceRequest[S]& request, DistanceResult[S]& result)


cdef extern from "fcl/geometry/bvh/BVH_internal.h" namespace "fcl":
    cdef enum BVHModelType:
        BVH_MODEL_UNKNOWN,    # unknown model type
        BVH_MODEL_TRIANGLES,  # triangle model
        BVH_MODEL_POINTCLOUD  # point cloud model

    cdef enum  BVHReturnCode:
        BVH_OK = 0,                              # BVH is valid
        BVH_ERR_MODEL_OUT_OF_MEMORY = -1,        # Cannot allocate memory for vertices and triangles
        BVH_ERR_BUILD_OUT_OF_SEQUENCE = -2,      # BVH construction does not follow correct sequence
        BVH_ERR_BUILD_EMPTY_MODEL = -3,          # BVH geometry is not prepared
        BVH_ERR_BUILD_EMPTY_PREVIOUS_FRAME = -4, # BVH geometry in previous frame is not prepared
        BVH_ERR_UNSUPPORTED_FUNCTION = -5,       # BVH funtion is not supported
        BVH_ERR_UNUPDATED_MODEL = -6,            # BVH model update failed
        BVH_ERR_INCORRECT_DATA = -7,             # BVH data is not valid
        BVH_ERR_UNKNOWN = -8                     # Unknown failure

    cdef enum BVHBuildState:
        BVH_BUILD_STATE_EMPTY,         # empty state, immediately after constructor
        BVH_BUILD_STATE_BEGUN,         # after beginModel(), state for adding geometry primitives
        BVH_BUILD_STATE_PROCESSED,     # after tree has been build, ready for cd use
        BVH_BUILD_STATE_UPDATE_BEGUN,  # after beginUpdateModel(), state for updating geometry primitives
        BVH_BUILD_STATE_UPDATED,       # after tree has been build for updated geometry, ready for ccd use
        BVH_BUILD_STATE_REPLACE_BEGUN, # after beginReplaceModel(), state for replacing geometry primitives

cdef extern from "fcl/math/triangle.h" namespace "fcl":
    cdef cppclass Triangle:
        Triangle() except +
        Triangle(size_t p1, size_t p2, size_t p3) except +
        size_t vids[3]

cdef extern from "fcl/geometry/bvh/detail/BV_splitter_base.h" namespace "fcl::detail":
    cdef cppclass BVSplitterBase[BV]:
        pass

cdef extern from "fcl/geometry/bvh/detail/BV_fitter_base.h" namespace "fcl::detail":
    cdef cppclass BVFitterBase[BV]:
        pass

# @TODO: Define some BVS, BVs are not complete
cdef extern from "fcl/math/bv/OBBRSS.h" namespace "fcl":
    cdef cppclass OBBRSS[S]:
        pass

cdef extern from "fcl/geometry/bvh/BVH_model.h" namespace "fcl":
    # Cython only accepts type template parameters.
    # see https://groups.google.com/forum/#!topic/cython-users/xAZxdCFw6Xs
    # @TODO: more links on stack-overflow coming

    cdef cppclass BVHModel[BV](CollisionGeometry[BV_S]):
        
        # Model type described by the instance
        BVHModelType getModelType()

        # Constructing an empty BVH
        BVHModel() except +
        BVHModel(BVHModel& other) except +
        #
        #Geometry point data
        Vector3[BV_S]* vertices
        #
        #Geometry triangle index data, will be NULL for point clouds
        Triangle* tri_indices
        #
        #Geometry point data in previous frame
        Vector3[BV_S]* prev_vertices
        #
        #Number of triangles
        int num_tris
        #
        #Number of points
        int num_vertices
        #
        #The state of BVH building process
        BVHBuildState build_state
        #
        # # #Split rule to split one BV node into two children
        #
        # boost::shared_ptr<BVSplitterBase<BV> > bv_splitter
        shared_ptr[BVSplitterBase[BV]] bv_splitter
        # boost::shared_ptr<BVFitterBase<BV> > bv_fitter
        shared_ptr[BVFitterBase[BV]] bv_fitter

        int getNumBVs()

        int beginModel(int num_tris_, int num_vertices_)

        int addVertex(const Vector3[BV_S]& p)

        int addTriangle(const Vector3[BV_S]& p1, const Vector3[BV_S]& p2, const Vector3[BV_S]& p3)

        #int addSubModel(const std::vector<Vector3[BV_S]>& ps)
        # void getCostSources(vector[CostSource]& cost_sources_)

        #int addSubModel(const vector[Vector3[BV_S]]& ps)
        #
        int addSubModel(const vector[Vector3[BV_S]]& ps, const vector[Triangle]& ts)

        int endModel()

        int buildTree()

        # void computeLocalAABB()

# @TODO: Support OcTree later
# cdef extern from "fcl/octree.h" namespace "fcl":
#     cdef cppclass OcTree(CollisionGeometry):
#         # Constructing
#         OcTree(FCL_REAL resolution) except +
#         OcTree(shared_ptr[octomap.OcTree]& tree_) except +

