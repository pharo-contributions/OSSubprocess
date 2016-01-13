tests
testBasicCommandReadFromStdout
	| command stdOutString | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: (Array with: Smalltalk image imageName).
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: Smalltalk image imageName).