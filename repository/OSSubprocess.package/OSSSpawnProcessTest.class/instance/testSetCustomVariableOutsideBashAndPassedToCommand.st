tests - env
testSetCustomVariableOutsideBashAndPassedToCommand
	| command outputString | 

 	command := OSSSpawnProcess new 
					command: '/bin/echo';
					arguments: (Array with: '${WHATEVER}');
					environmentAt: 'WHATEVER' put: 'hello'.

	self shouldnt: [ command run ] raise: Error. 
	outputString := command stdoutStream upToEndOfFile.
	self assert: outputString trimmed equals: 'hello'. 