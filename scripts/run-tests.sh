#!/bin/bash 

set -ex

wget --quiet -O - get.pharo.org/alpha+vm | bash

./pharo Pharo.image eval --save "
Metacello new 
	baseline: 'OSSubprocess';
	repository: 'filetree://repository';
	load.
"

./pharo Pharo.image test --no-xterm --fail-on-failure "OSSubprocess.*" 2>&1
