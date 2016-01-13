tests - basic
testBasicCommandWithoutFullPath
	| command stdOutString | 
	
	command := OSSSpawnProcess new 
					command: 'ls';
					arguments: (Array with: Smalltalk image imagePath).
	
	self shouldnt: [ command run ] raise: Error. 
	stdOutString := command stdoutStream upToEndOfFile.
	self assert: (stdOutString includesSubstring: Smalltalk image imagePath).