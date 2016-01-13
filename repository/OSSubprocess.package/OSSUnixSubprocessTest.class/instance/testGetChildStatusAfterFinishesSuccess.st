tests - child status
testGetChildStatusAfterFinishesSuccess
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand
					command: '/bin/ls'.
	
	command run. 
	self assert: command childPid > 0.
	command waitForChild.
	command queryExitStatus.
	self assert: command exitStatusInterpreter exitStatus equals: 0. 
	self assert: command succeeded.
	self assert: command completed.
	self deny: command isRunning.
	self assert: self numberOfZombiesProcesses equals: oldZombies.