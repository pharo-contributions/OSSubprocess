tests - streams
testCreateMissingStandardStreamsEnabled
	| command numberOfOpenFiles | 
	
	numberOfOpenFiles := self numberOfOpenFiles.
	"The output of the ls command should be displayed in the stdout of the Pharo image. See comment of #createPipesForMissingStreams: for more details"
	command := self newCommand
					command: '/bin/ls';
					createMissingStandardStreams: true.
					
	command run. 
	self assert: command stdinStream isNil not.
	self assert: command stdoutStream isNil not.
	self assert: command stderrStream isNil not.
	command closeAndDeleteStandardStreams.
	self assert: self numberOfOpenFiles equals: numberOfOpenFiles
	