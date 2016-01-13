tests - streams
testCustomStdoutStream
	| customStream numberOfOpenFiles | 
	numberOfOpenFiles := self numberOfOpenFiles.
	customStream := self newCommand createADefaultWriteStream.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		stdoutStream: customStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assert: command stdoutStream == customStream	.				
			self assert: self numberOfOpenFiles equals: numberOfOpenFiles
		].
	
	

