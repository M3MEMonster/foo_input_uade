#!/bin/bash

export PYTHONPATH="$(realpath "$(dirname "${0}")/..")"
ret=0
for unittest in *_test.py ; do
    if [ ! -e "${unittest}" ] ; then
	break
    fi
    echo "Run unittest ${unittest}"
    env python3 "${unittest}" || ret=1
done

if [[ ${ret} != 0 ]] ; then
    exit ${ret}
fi

flake8
if [[ $? != 0 ]] ; then
    echo "flake8 failed"
    exit 1
fi
