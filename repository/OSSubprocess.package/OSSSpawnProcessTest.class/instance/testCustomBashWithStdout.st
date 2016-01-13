tests - bash
testCustomBashWithStdout
	| command stdOutString | 
	
	command := OSSSpawnProcess new 
					bash: '/bin/bash' command: 'ls ', Smalltalk image imagePath;
					createAndSetStdoutPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: Smalltalk image imagePath).	
