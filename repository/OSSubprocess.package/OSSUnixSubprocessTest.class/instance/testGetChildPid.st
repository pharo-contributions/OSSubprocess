tests - child status
testGetChildPid
	| command | 
	
	command := self newCommand 
					command: '/bin/ls'.
	
	command run.
	self assert: command childPid > 0.