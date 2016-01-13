tests - child status
testCheckZombieStateAndThenWait
	| command oldZombies | 
	oldZombies := self numberOfZombiesProcesses.
	command := self newCommand 
				command: '/bin/sleep';
				arguments: {'1'}.
	
	command run. 
	self assert: command childPid > 0.
	(Duration seconds: 2) wait.
	"The child process has finished, yet we haven't retrieved it's exit status yet.
	So it must be a zombie"
	self assert: self numberOfZombiesProcesses equals: oldZombies + 1.
	self assert: command queryExitStatus isNil not.
	"Now it should not be a zombie anymore"
	self assert: self numberOfZombiesProcesses equals: oldZombies.
	
	