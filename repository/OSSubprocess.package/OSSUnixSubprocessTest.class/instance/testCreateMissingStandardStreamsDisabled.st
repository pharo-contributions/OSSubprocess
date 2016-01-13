tests - streams
testCreateMissingStandardStreamsDisabled
	| command | 
	
	command := self newCommand
					command: '/bin/ls'.
					
	command run. 
	self assert: command stdinStream isNil.
	self assert: command stdoutStream isNil.
	self assert: command stderrStream isNil.
	