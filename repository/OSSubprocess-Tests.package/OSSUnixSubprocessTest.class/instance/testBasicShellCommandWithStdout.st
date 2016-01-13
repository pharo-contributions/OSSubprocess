tests - shell
testBasicShellCommandWithStdout

	self newCommand
		shellCommand: 'ls ', Smalltalk image imagePath;
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).						
		]
		 
