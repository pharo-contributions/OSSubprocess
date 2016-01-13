tests - streams
testBasicCommandReadFromStdout
	| oldNumberOfOpenFiles |
	oldNumberOfOpenFiles := self numberOfOpenFiles.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assert: self numberOfOpenFiles equals: oldNumberOfOpenFiles.
		].
	
	