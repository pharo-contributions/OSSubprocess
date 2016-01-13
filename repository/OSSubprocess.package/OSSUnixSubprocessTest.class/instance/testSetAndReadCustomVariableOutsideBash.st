tests - env
testSetAndReadCustomVariableOutsideBash
	self newCommand 
		command: 'printenv';
		arguments: (Array with: 'WHATEVER');
		environmentAt: 'WHATEVER' put: 'hello';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: 'hello'. 					
		]
