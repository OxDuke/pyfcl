import os
import sys
import inspect

from setuptools import setup, Extension
from Cython.Build import cythonize

# get current directory of file in case someone
# called setup.py from elsewhere
cwd = os.path.dirname(os.path.abspath(
    inspect.getfile(inspect.currentframe())))

# load __version__
exec(open(os.path.join(cwd,
                       'pyfcl/version.py'), 'r').read())

ext_modules=[
    Extension("pyfcl.pyfcl", ["pyfcl/pyfcl.pyx"],
    #@TODO: better include for include/eigen_wrapper.h
    include_dirs = ['/usr/local/include', '/usr/include/eigen3', 'include/', '/usr/local/include/eigen3'],
    #@TODO: remove: '/usr/local/lib:/opt/ros/lunar/lib'
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
  author_email='464604837@qq.com',
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

  # Support Python2.7 & All Python3 start from Python3.5
  python_requires='>=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, !=3.4.*,<4',
  
  ext_modules = cythonize(ext_modules),
  zip_safe=False
)
