tests - env
testSetAndReadCustomVariable
	self newCommand 
		bashCommand: 'echo ${WHATEVER}';
		environmentAt: 'WHATEVER' put: 'hello';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: outString trimmed equals: 'hello'
		]
