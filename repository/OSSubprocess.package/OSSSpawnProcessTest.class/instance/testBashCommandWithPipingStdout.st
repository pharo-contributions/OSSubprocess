tests - bash
testBashCommandWithPipingStdout
	| command stdOutString | 
	
	command := OSSSpawnProcess new 
					bashCommand: 'ps -fea | grep Pharo';
					createAndSetStdoutPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: 'Pharo').	
