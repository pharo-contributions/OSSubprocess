tests - bash
testBashCommandWithPipingStdout

	self newCommand
		bashCommand: 'ps -fea | grep Pharo';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: 'Pharo').						
		]
		 
