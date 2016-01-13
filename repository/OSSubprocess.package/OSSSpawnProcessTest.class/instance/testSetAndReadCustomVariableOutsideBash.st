tests - env
testSetAndReadCustomVariableOutsideBash
	| command outputString | 

 	command := OSSSpawnProcess new 
					command: 'printenv';
					arguments: (Array with: 'WHATEVER');
					environmentAt: 'WHATEVER' put: 'hello';
					createAndSetStdoutPipe.

	self shouldnt: [ command run ] raise: Error. 
	outputString := command stdoutStream upToEndOfFile.
	self assert: outputString trimmed equals: 'hello'. 