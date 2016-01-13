tests - streams
testCreatePipesForMissingStreamsEnabled
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					createPipesForMissingStreams: true.
					
	self shouldnt: [ command run ] raise: Error. 
	self assert: command stdinStream isNil not.
	self assert: command stdoutStream isNil not.
	self assert: command stderrStream isNil not.
	