tests - wait
testWaitForChild
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/sleep';
					arguments: {'3'}.
	
	self shouldnt: [ command run ] raise: Error. 
	command childPid > 0.
	self assert: [ command waitForChild ] timeToRun asSeconds >= 2.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 