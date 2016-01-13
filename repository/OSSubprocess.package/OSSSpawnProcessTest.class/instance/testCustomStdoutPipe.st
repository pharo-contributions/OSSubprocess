tests - streams
testCustomStdoutPipe
	| command stdOutString customPipe | 
	customPipe := OSSSystemAccessor current makePipe.
	command := OSSSpawnProcess new
					command: '/bin/ls';
					arguments: (Array with: Smalltalk image imagePath);
					stdoutPipe: customPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: Smalltalk image imagePath).
	self assert: command stdoutPipe == customPipe