tests
testGetChildStatusAfterFinishesSuccess
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls'.
	
	self shouldnt: [ command run ] raise: Error. 
	command childPid > 0.
	(Duration seconds: 1) wait.
	self assert: command getChildStatus exitStatus equals: 0. 