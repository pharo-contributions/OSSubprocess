#!/bin/bash 

set -ex

wget --quiet -O - get.pharo.org/alpha+vm | bash

./pharo Pharo.image eval --save "
Metacello new 
	baseline: 'OSSubprocess';
	repository: 'filetree://repository';
	load.
	
	Gofer it
		url: 'http://smalltalkhub.com/mc/Pharo/Pharo50Inbox/main';
		package: 'SLICE-Issue-17490-Command-Line-Handler-test-runner-should-print-a-small-stack-for-failures-and-errors';
	load.	
"

./pharo Pharo.image test --no-xterm --fail-on-failure "OSSubprocess.*" 2>&1
