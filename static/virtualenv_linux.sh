#!/bin/bash

# This script assumes you are running on a Linux system with python3 and
# other dependencies (boost, MPI, cfitsio, etc) installed using OS packages.
# It further assumes that you have created a virtualenv and have activated
# it.  We will be installing packages into this virtualenv with pip.

# Are we running in a virtualenv?  We should be!

if [ "x${VIRTUAL_ENV}" = x ]; then
    echo ""
    echo "  No virtualenv is currently active.  You should source the"
    echo "  <prefix>/bin/activate file before running this script"
    echo ""
    exit 1
fi
prefix="${VIRTUAL_ENV}"

# What is our version suffix?
pyver=$(python --version 2>&1 | awk '{print $2}' | sed -e "s#\(.*\)\.\(.*\)\..*#\1.\2#")

# Script directory and top-level directory

pushd $(dirname $0) > /dev/null
sdir=$(pwd)
popd > /dev/null
scriptname=$(basename $0)
fullscript="${sdir}/${scriptname}"
topdir="${sdir}/.."

# The bin directory and site-packages should already be in PATH and PYTHONPATH
# from the activation of the virtualenv.  Now export some additional variables
# needed for compiled packages.

export CPATH="${prefix}/include":${CPATH}
export LIBRARY_PATH="${prefix}/lib":${LIBRARY_PATH}
export LD_LIBRARY_PATH="${prefix}/lib":${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig":${PKG_CONFIG_PATH}
export PKG_CONFIG_PATH="${prefix}/share/pkgconfig":${PKG_CONFIG_PATH}

# Install pip packages.

pip install \
    nose \
    requests \
    future \
    numpy \
    scipy \
    matplotlib \
    pyyaml \
    coveralls \
    h5py \
    psutil \
    ephem \
    astropy==2.0.9 \
    psycopg2 \
    pytest \
    pytest-cov \
    numba \
    sqlalchemy \
    scikit-learn \
    scikit-image \
    ipython \
    jupyter \
    ipywidgets \
    cython \
    bokeh \
    seaborn \
    line_profiler

pip install --no-binary :all: \
    speclite \
    hpsspy \
    photutils \
    healpy \
    https://github.com/esheldon/fitsio/archive/v0.9.12rc1.zip

# Copy patches

if [ ! -e ./conf ]; then
    # this is an out-of-source build, copy patches
    rm -rf ./rules
    mkdir ./rules
    cp ${topdir}/rules/patch_* ./rules/
fi

# Install HARP.

curl -SL https://github.com/tskisner/HARP/releases/download/v1.0.5/harp-1.0.5.tar.bz2 \
    -o harp-1.0.5.tar.bz2 \
    && tar xjf harp-1.0.5.tar.bz2 \
    && cd harp-1.0.5 \
    && CC="gcc" CXX="g++" \
    CFLAGS="-O3 -fPIC -pthread" \
    CXXFLAGS="-O3 -fPIC -pthread" \
    ./configure  \
    --disable-mpi --disable-python \
    --prefix=${prefix} \
    && make -j 2 && make install \
    && cd .. \
    && rm -rf harp*

# GalSim and dependencies

 curl -SL https://github.com/rmjarvis/tmv/archive/v0.75.tar.gz \
    -o tmv-0.75.tar.gz \
    && tar xzf tmv-0.75.tar.gz \
    && cd tmv-0.75 \
    && scons PREFIX="${prefix}" \
    CXX="g++" FLAGS="-O3 -fPIC -pthread" \
    EXTRA_INCLUDE_PATH="" \
    EXTRA_LIB_PATH=$(echo -lopenblas -fopenmp -lpthread -lgfortran -lm | sed -e 's#-[^L]\S\+##g' | sed -e 's#-L\(\S\+\).*#\1#g') \
    LIBS="$(echo -lopenblas -fopenmp -lpthread -lgfortran -lm | sed -e 's#-[^l]\S\+##g' | sed -e 's#-l\(\S\+\)#\1#g')" \
    FORCE_FBLAS=true \
    && scons PREFIX="${prefix}" install \
    && cd .. \
    && rm -rf tmv*

 curl -SL https://github.com/GalSim-developers/GalSim/archive/v1.5.1.tar.gz \
    -o GalSim-1.5.1.tar.gz \
    && tar xzf GalSim-1.5.1.tar.gz \
    && cd GalSim-1.5.1 \
    && scons PREFIX="${prefix}" \
    CXX="g++" FLAGS="-O3 -fPIC -pthread -std=c++98" \
    TMV_DIR="${prefix}" \
    EXTRA_INCLUDE_PATH="${prefix}/include" \
    EXTRA_LIB_PATH="${prefix}/lib" \
    && scons PREFIX="${prefix}" install \
    && cd .. \
    && rm -rf GalSim*

# Remove patches if needed

if [ ! -e ./conf ]; then
    # this is an out-of-source build
    rm -rf ./rules
fi

# Compile python modules

python -m compileall -f "${prefix}/lib/python${pyver}/site-packages"

# Import packages that may need to generate files in the
# install prefix

python -c "import astropy"
python -c "import matplotlib.font_manager as fm; f = fm.FontManager"

# Install plain shell setup

setupfile="${prefix}/setup.sh"
echo "# Load desi dependencies into the environment" > "${setupfile}"
echo "source ${prefix}/bin/activate" >> "${setupfile}"
echo "export CPATH=${prefix}/include:\${CPATH}" >> "${setupfile}"
echo "export LIBRARY_PATH=${prefix}/lib:\${LIBRARY_PATH}" >> "${setupfile}"
echo "export LD_LIBRARY_PATH=${prefix}/lib:\${LD_LIBRARY_PATH}" >> "${setupfile}"
echo "export PKG_CONFIG_PATH=${prefix}/lib/pkgconfig:\${PKG_CONFIG_PATH}" >> "${setupfile}"
echo "export PKG_CONFIG_PATH=${prefix}/share/pkgconfig:\${PKG_CONFIG_PATH}" >> "${setupfile}"
echo "" >> "${setupfile}"
