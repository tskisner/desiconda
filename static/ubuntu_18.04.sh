#!/bin/bash

# For Ubuntu 18.10:  install OS dependencies for DESI.  This assumes that
# you will be installing the DESI dependencies in a virtualenv using the
# scripts in this directory.  You only need to run this script once.  Run this
# script using "sudo" or as root.

apt-get update

apt-get install -y \
    curl procps build-essential g++ gfortran git subversion \
    autoconf automake libtool m4 cmake locales libgl1-mesa-glx xvfb \
    libfftw3-dev \
    libopenblas-dev \
    liblapack-dev \
    liblapacke-dev \
    libcfitsio-dev \
    fitsverify \
    libhdf5-dev \
    libopenmpi-dev \
    libboost-all-dev \
    scons \
    python3 \
    libpython3-dev \
    python3-pip \
    virtualenv \
    python3-virtualenv
