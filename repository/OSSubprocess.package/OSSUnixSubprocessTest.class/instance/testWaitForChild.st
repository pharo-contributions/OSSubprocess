tests - wait
testWaitForChild
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'3'}.
	
	command run. 
	self assert: command childPid > 0.
	self assert: [ command waitForChild ] timeToRun asSeconds >= 2.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 