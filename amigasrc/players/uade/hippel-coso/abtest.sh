#!/bin/bash

dname=$1
if [[ -z ${dname} ]] ; then
    echo "Give directory of hipc songs"
    exit 1
fi

mkdir -p synth
find "${dname}" -type f |while read fname ; do
    echo "Synthesizing $fname"
    bname=$(basename "${fname}")
    for player in hipc newhipc ; do
	uade123 -f tmp.wav -P "${player}" "${fname}"
	# sox tmp.wav "synth/${bname}_${player}.wav" silence 1 0.1 1%
	mv tmp.wav "synth/${bname}_${player}.wav"
    done
done
