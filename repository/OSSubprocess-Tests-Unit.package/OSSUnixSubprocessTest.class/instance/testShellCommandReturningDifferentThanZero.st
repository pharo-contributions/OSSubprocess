tests - wait
testShellCommandReturningDifferentThanZero
	| command | 
	
	command := self newCommand shellCommand: 'exit 2'.
	command runAndWait. 
	
	self assert: command exitStatusInterpreter exitStatus equals: 2. 