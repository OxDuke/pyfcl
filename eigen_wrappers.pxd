
from fcl_defs cimport Matrix3, Quaternion, Transform3


cdef extern from "eigen_wrapper.hpp":
    
    Matrix3[T] Matrix3FromNumbers[T](const T& xx, const T& xy , const T& xz,const T& yx, const T& yy , const T& yz,const T& zx, const T& zy , const T& zz)
    void Matrix3SetValue[T](Matrix3[T]&, size_t, const T&)
    
    #void Matrix3SetValue[T](Matrix3[T]&, size_t, size_t, const T&)

    void QuaternionSetw[T](Quaternion[T]&, const T&)
    
    void Transform3SetLinear[T](Transform3[T]& t, const T& xx, const T& xy , const T& xz,const T& yx, const T& yy , const T& yz,const T& zx, const T& zy , const T& zz)
    void Transform3SetTranslation[T](Transform3[T]&, const T&, const T&, const T&)