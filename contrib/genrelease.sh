#!/bin/bash

if [[ ! -e version ]] ; then
    echo "Run this script in the main directory of the repository where the "
    echo "version file lies."
    exit 1
fi
version=$(cat version)
echo "Generating uade-${version}.tar.bz2"
archivename="uade-${version}.tar.bz2"
git archive --prefix="uade-${version}"/ "uade-${version}" |bzip2 >"${archivename}"
chmod a+r "${archivename}"
