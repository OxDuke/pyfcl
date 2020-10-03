
from fcl_defs cimport Vector3, Matrix3, Quaternion, Transform3


#@TODO: Change all [T] to: cimport Scalar & [T] -> [Scalar]
cdef extern from "eigen_wrapper.hpp":
    
    Matrix3[T] Matrix3FromNumbers[T](const T& xx, const T& xy , const T& xz,const T& yx, const T& yy , const T& yz,const T& zx, const T& zy , const T& zz)
    void Matrix3SetValue[T](Matrix3[T]&, size_t, const T&)
    
    #void Matrix3SetValue[T](Matrix3[T]&, size_t, size_t, const T&)

    void QuaternionSetw[T](Quaternion[T]&, const T&)

    void Transform3SetIdentity[T](Transform3[T]& tf)
    
    # @TODO: Currently, these functions are only used for assembling Transform,
    # However, I think they are not direct enough, I will profile these
    # functions and probably switch to more direct implementations
    void Transform3FromMatrix3Vector3[T](Transform3[T]& tf, const Matrix3[T]& R, const Vector3[T]& v)
    void Transform3FromQuaternionVector3[T](Transform3[T]& tf, const Quaternion[T]& q, const Vector3[T]& v)
    void Transform3FromMatrix3[T](Transform3[T]& tf, const Matrix3[T]& R)
    void Transform3FromQuaternion[T](Transform3[T]& tf, const Quaternion[T]& q)
    
    Transform3[T] Transform3FromVector3[T](const Vector3[T]& v)    
    void Transform3FromVector3Numbers[T](Transform3[T]& tf, const T& x, const T& y, const T& z)


    void Transform3SetLinear[T](Transform3[T]& tf, const T& xx, const T& xy , const T& xz,const T& yx, const T& yy , const T& yz,const T& zx, const T& zy , const T& zz)
    void Transform3SetTranslation[T](Transform3[T]& tf, const T&, const T&, const T&)