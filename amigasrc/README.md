== amigasrc tree ==
amigasrc/ directory hierarchy contains source files and binaries with
many different licenses. All source files (except perhaps headers) should
contain a license. e.g. score/score.s is licensed with GNU LGPL.

DO NOT MAKE EASY ASSUMPTIONS ABOUT LICENSES OF SOURCE CODE FILES FOUND
UNDER THIS DIRECTORY HIERARCHY

All these files are certainly distributable, but some are not Open Source
Initiative approved.

== Notes on compiling with vasm ==

For compiling eagleplayers with asm, use the following arguments:

$ vasm.vasmm68k-mot -no-opt -Fhunkexe -nosym -I path/to/amigasrc/score
