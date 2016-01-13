tests - streams
testBasicCommandReadFromStdout
	| streamsInfo |
	streamsInfo := self getStreamsInfoForRunningTest.
	self newCommand
		command: '/bin/ls';
		arguments: (Array with: Smalltalk image imagePath);
		createAndSetStdoutStream;
		runAndWaitOnExitDo: [ :command :outString |
			self assert: (outString includesSubstring: Smalltalk image imagePath).
			self assertStreamsInfoWithPrevious: streamsInfo.
		].
	
	