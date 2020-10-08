
from setuptools import setup, Extension
from Cython.Build import cythonize

from version import __version__

ext_modules=[
    Extension("pyfcl", ["pyfcl.pyx"],
    #@TODO: better include for include/eigen_wrapper.h
    include_dirs = ['/usr/local/include', '/usr/include/eigen3', 'include/', '/usr/local/include/eigen3'],
    library_dirs = ['/usr/lib', '/usr/local/lib','/usr/local/lib:/opt/ros/lunar/lib'],
    libraries=["fcl","ccd", "stdc++"],
    language="c++",
    extra_compile_args = ["-std=c++11"])]

setup(
  name = 'PyFCL',
  version = __version__,
  author='Weidong Sun',
  author_email='me@weidongsun.com',
  ext_modules = cythonize(ext_modules),
  zip_safe=False
)
