tests - streams
testCreatePipesForMissingStreamsDisabled
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls'.
					
	self shouldnt: [ command run ] raise: Error. 
	self assert: command stdinStream isNil.
	self assert: command stdoutStream isNil.
	self assert: command stderrStream isNil.
	