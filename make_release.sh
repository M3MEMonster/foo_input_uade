#!/bin/bash

version="$(cat version)"
fname="uade-${version}.tar.bz2"
echo -n "Create ${fname}? (y/n) "
read reply
if [[ "${reply}" = "y" ]] ; then
    git archive --format tar --prefix="uade-${version}/" HEAD |bzip2 >"${fname}"
else
    echo "Error"
    exit 1
fi

										
