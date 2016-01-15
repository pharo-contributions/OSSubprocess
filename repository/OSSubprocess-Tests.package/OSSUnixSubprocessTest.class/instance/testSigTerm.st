tests - signals
testSigTerm

	| process exited streamsInfo |
	
	exited := false.
	streamsInfo := self getStreamsInfoForRunningTest.
	process := self newCommand.
	
	[
	process 
		command: 'tail';
		arguments: #('-f' '/var/log/system.log' );
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: (Delay forMilliseconds: 500) 
		doing: [ :aProcess :outStream :errStream |  
		 	outStream upToEnd.
			errStream upToEnd.
		]
		onExitDo: [ :aProcess :outStream :errStream  |
			process closeAndCleanStreams.
			exited := true.
		].
	] fork.

	(Delay forSeconds: 2) wait. 
	process sigterm. 
	(Delay forSeconds: 1) wait. 
	self assert: exited.	
	self assertStreamsInfoWithPrevious: streamsInfo.
