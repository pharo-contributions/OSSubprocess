tests
testRedirectSdErrToStdOut
	| command | 
	
	command := OSSPopenCommand new 
					beRead;
					command: 'whatever';
					redirectSdErrToStdOut: true.
				
	self shouldnt: [ command run ] raise: Error.
	self assert: (command pipeStream upToEndOfFile includesSubstring: 'command not found').
	command closeStreams.
	self assert: command terminationStatus > 0.
	self assert: command exitStatus exitStatus equals: 127