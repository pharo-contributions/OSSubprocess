tests
testWaitpidIsNoneBocking
	| command childStatus | 
	
	command := OSSSpawnProcess new 
					command: '/bin/sleep';
					arguments: {'5'}.
	
	self shouldnt: [ command run ] raise: Error. 
	command childPid > 0.
	(Duration seconds: 1) wait.
	self assert: [ childStatus := command getChildStatus ] timeToRun asSeconds < 1.
	self assert: childStatus isNil