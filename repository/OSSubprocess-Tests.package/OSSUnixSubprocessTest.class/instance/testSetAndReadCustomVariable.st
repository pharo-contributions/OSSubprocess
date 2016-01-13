tests - env
testSetAndReadCustomVariable
	self newCommand 
		shellCommand: 'echo ${WHATEVER}';
		environmentAt: 'WHATEVER' put: 'hello';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: 'hello'
		]
