tests - streams
testCreatePipesForMissingStreamsEnabled
	| command | 
	"The output of the ls command should be displayed in the stdout of the Pharo image. See comment of #createPipesForMissingStreams: for more details"
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					createPipesForMissingStreams: true.
					
	self shouldnt: [ command run ] raise: Error. 
	self assert: command stdinStream isNil not.
	self assert: command stdoutStream isNil not.
	self assert: command stderrStream isNil not.
	