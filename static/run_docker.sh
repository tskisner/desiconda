#!/bin/bash
#
# Run this script to launch a container for build testing.  Run the script
# from the current directory.  Example:
#
#    %> ./static/run_docker.sh ubuntu:18.04
#
# This current directory will be mounted at /scripts inside the image.
#

usage () {
    echo "$0 <container tag>"
    exit 1
}

cont="$1"
if [ "x${cont}" = "x" ]; then
    usage
    exit 1
fi

build_id="build-${RANDOM}"
scrsource=$(pwd)
scrtarget="/scripts"

docker run --name ${build_id} --mount type=bind,source=${scrsource},target=${scrtarget} -it ${cont} bash -l
