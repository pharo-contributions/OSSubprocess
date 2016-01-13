tests
testGetChildPid
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls'.
	
	self shouldnt: [ command run ] raise: Error. 
	command childPid > 0.