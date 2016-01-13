tests - bash
testBasicBashCommandWithStdout
	| command stdOutString | 
	
	command := OSSSpawnProcess new 
					bashCommand: 'ls ', Smalltalk image imagePath;
					createAndSetStdoutPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: Smalltalk image imagePath).	
