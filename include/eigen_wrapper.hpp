#include "fcl/common/types.h"

template<typename T>
fcl::Matrix3<T> Matrix3FromNumbers(const T& xx, const T& xy , const T& xz,
	const T& yx, const T& yy , const T& yz,
	const T& zx, const T& zy , const T& zz)
{
	// @TODO: Is there a faster/more efficient way to fill in the 9 numbers?
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
void Transform3FromMatrix3Vector3(fcl::Transform3<T>& tf, const fcl::Matrix3<T>& R, const fcl::Vector3<T>& v)
{
	tf.linear() = R;
	tf.translation() = v;
}

template<typename T>
void Transform3FromQuaternionVector3(fcl::Transform3<T>& tf, const fcl::Quaternion<T>& q, const fcl::Vector3<T>& v)
{
	tf.linear() = q.toRotationMatrix();
	tf.translation() = v;
}

template<typename T>
void Transform3FromMatrix3(fcl::Transform3<T>& tf, const fcl::Matrix3<T>& R)
{
	tf.linear() = R;
}

template<typename T>
void Transform3FromQuaternion(fcl::Transform3<T>& tf, const fcl::Quaternion<T>& q)
{
	tf.linear() = q.toRotationMatrix();
}

// template<typename T>
// fcl::Transform3<T> Transform3FromQuaternionComponents(const T& w, const T& x, const T& y, const T& z)
// {
// 	fcl::Transform3<T> tf;
// 	tf.linear() = q.toRotationMatrix();
// 	return tf;
// }

template<typename T>
fcl::Transform3<T> Transform3FromVector3(const fcl::Vector3<T>& v)
{
	fcl::Transform3<T> tf;
	tf.translation() = v;
	return tf;
}

template<typename T>
void Transform3FromVector3Numbers(fcl::Transform3<T>& tf, const T& x, const T& y, const T& z)
{
	tf.translation() = fcl::Vector3<T>(x, y, z);
}

template<typename T>
void Transform3SetLinear(fcl::Transform3<T>& tf, 
	const T& xx, const T& xy , const T& xz,
	const T& yx, const T& yy , const T& yz,
	const T& zx, const T& zy , const T& zz)
{
	fcl::Matrix3<T> temp_mat;
	temp_mat << xx, xy , xz, yx, yy , yz, zx, zy , zz;
	tf.linear() = temp_mat;
}

template<typename T>
void Transform3SetTranslation(fcl::Transform3<T>& tf, const T& x, const T& y , const T& z)
{
	tf.translation() = fcl::Vector3<T>(x,y,z);
}
