tests - bash
testBasicBashCommandWithStdout

	self newCommand
		bashCommand: 'ls ', Smalltalk image imagePath;
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).						
		]
		 
