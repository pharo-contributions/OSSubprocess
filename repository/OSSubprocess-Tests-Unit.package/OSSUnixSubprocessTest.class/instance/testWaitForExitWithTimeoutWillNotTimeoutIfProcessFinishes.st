tests - wait
testWaitForExitWithTimeoutWillNotTimeoutIfProcessFinishes
	| command | 
	
	command := self newCommand 
					command: '/bin/sleep';
					arguments: {'1'}.
	
	command run.
	command waitForExitWithTimeout: 2 seconds.
	
	self assert: command pid > 0.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 