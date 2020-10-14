
from setuptools import setup, Extension
from Cython.Build import cythonize

from version import __version__

ext_modules=[
    Extension("pyfcl", ["pyfcl.pyx"],
    #@TODO: better include for include/eigen_wrapper.h
    include_dirs = ['/usr/local/include', '/usr/include/eigen3', 'include/', '/usr/local/include/eigen3'],
    library_dirs = ['/usr/lib', '/usr/local/lib','/usr/local/lib:/opt/ros/lunar/lib'],
    libraries=["fcl","ccd"],
    language="c++",
    extra_compile_args = ["-std=c++11"])]

setup(
  name = 'pyfcl',
  version = __version__,
  description = "FCL Python wrappers",
  long_description = "Python wrappers for the Flexible Collision Library",
  url="https://github.com/OxDuke/pyfcl",
  author='Weidong Sun',
  author_email='swdswd28@foxmail.com',
  license = "BSD",
  classifiers=[
      'Development Status :: 2 - Pre-Alpha',
      'License :: OSI Approved :: BSD License',
      'Operating System :: POSIX :: Linux',
      'Programming Language :: Python :: 2',
      'Programming Language :: Python :: 2.7',
      'Programming Language :: Python :: 3',
      'Programming Language :: Python :: 3.5',
      'Programming Language :: Python :: 3.6',
      'Programming Language :: Python :: 3.7',
      'Programming Language :: Python :: 3.8',
  ],
  keywords='fcl collision distance',
  packages=['pyfcl'],
  setup_requires=['cython'],
  install_requires=['numpy', 'cython'],

  
  ext_modules = cythonize(ext_modules),
  zip_safe=False
)
