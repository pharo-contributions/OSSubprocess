tests - shell
testShellCommandWithPipingStdout

	self newCommand
		shellCommand: 'ps -fea | grep Pharo';
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: 'Pharo').						
		]
		 
