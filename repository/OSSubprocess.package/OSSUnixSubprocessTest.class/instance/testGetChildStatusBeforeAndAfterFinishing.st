tests - child status
testGetChildStatusBeforeAndAfterFinishing
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'3'}.
	
	command run. 
	self assert: command childPid > 0.
	(Duration seconds: 1) wait.
	self assert: command queryExitStatus isNil.
	self deny: command completed.
	self assert: command isRunning.
	command waitForChild.
	self assert: command queryExitStatus isNil not.
	self assert: command exitStatusInterpreter exitStatus equals: 0.
	self assert: command completed.
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	