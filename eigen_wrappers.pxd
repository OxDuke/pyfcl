
from fcl_defs cimport Matrix3, Quaternion


cdef extern from "eigen_wrapper.hpp":
    void Matrix3SetValue[T](Matrix3[T]&, size_t, const T&)
    #void Matrix3SetValue[T](Matrix3[T]&, size_t, size_t, const T&)

    void QuaternionSetw[T](Quaternion[T]&, const T&)