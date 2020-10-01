#include "fcl/common/types.h"

template<typename T>
fcl::Matrix3<T> Matrix3FromNumbers(const T& xx, const T& xy , const T& xz,
	const T& yx, const T& yy , const T& yz,
	const T& zx, const T& zy , const T& zz)
{
	fcl::Matrix3<T> temp_mat;
	temp_mat << xx, xy , xz, yx, yy , yz, zx, zy , zz;

	return temp_mat;

}
    

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

template<typename T>
void Transform3SetLinear(fcl::Transform3<T>& t, 
	const T& xx, const T& xy , const T& xz,
	const T& yx, const T& yy , const T& yz,
	const T& zx, const T& zy , const T& zz)
{
	fcl::Matrix3<T> temp_mat;
	temp_mat << xx, xy , xz, yx, yy , yz, zx, zy , zz;
	//fcl::Matrix3<T>
	t.linear() = temp_mat;
}

template<typename T>
void Transform3SetTranslation(fcl::Transform3<T>& t, const T& x, const T& y , const T& z)
{
	t.translation() = fcl::Vector3<T>(x,y,z);
}
