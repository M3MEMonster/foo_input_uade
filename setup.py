#!/usr/bin/env python3

from distutils.core import setup
import os

version = open('version').read().strip()

long_description = """uade"""

new_umask = 0o0022
print('Setting umask {:04o} for setup.py'.format(new_umask))
os.umask(new_umask)

setup(
    name='uade',
    version=version,
    description='uade',
    author='Heikki Orsila',
    author_email='heikki.orsila@iki.fi',
    url='https://gitlab.com/uade-music-player/uade',
    # py_modules=['uade'],
    # scripts=['generate_oscilloscope_view'],
    packages=['uade'],
    package_dir={'uade': 'python/uade'},
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: GNU General Public License v2 (GPLv2)',
        ('License :: OSI Approved :: GNU Lesser General Public License v2 '
         '(LGPLv2)'),
        'Operating System :: POSIX :: Linux',
        ],
    long_description=long_description,
    )
