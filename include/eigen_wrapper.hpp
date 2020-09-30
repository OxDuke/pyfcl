#include "fcl/common/types.h"

template<typename T>
void Matrix3SetValue(fcl::Matrix3<T> & m, size_t index, const T & v)
{
  m(index) = v;
}

// template<typename T>
// void Matrix3SetValue(fcl::Matrix3<T> & m, size_t row, size_t col, const T & v)
// {
//   m(row,col) = v;
// }

template<typename T>
void QuaternionSetw(fcl::Quaternion<T> & q, const T & w)
{
  q.w() = w;
}
