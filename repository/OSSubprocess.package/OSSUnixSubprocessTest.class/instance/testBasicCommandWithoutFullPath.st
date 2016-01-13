tests - basic
testBasicCommandWithoutFullPath

	self newCommand
		command: 'ls';
		arguments: (Array with: Smalltalk image imagePath);
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).					
		]
		 
