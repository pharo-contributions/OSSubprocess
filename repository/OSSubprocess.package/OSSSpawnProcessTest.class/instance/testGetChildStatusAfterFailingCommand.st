tests - child status
testGetChildStatusAfterFailingCommand
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: {'whatever'}.
	self shouldnt: [ command run ] raise: Error. 
	command childPid > 0.
	(Duration seconds: 1) wait.
	command queryExitStatus.
	self assert: command exitStatusInterpreter exitStatus equals: 1. 
	self deny: command succeeded.
	self assert: command completed.
	self deny: command isRunning.