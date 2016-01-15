tests - signals
testSigTermInsideLoop

	| process exited streamsInfo |
	
	exited := false.
	streamsInfo := self getStreamsInfoForRunningTest.
	process := self newCommand.
	
	process 
		command: 'tail';
		arguments: #('-f' '/var/log/system.log' );
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: (Delay forMilliseconds: 500) 
		doing: [ :aProcess :outStream :errStream |  
		 	"Imagine here that you have some condition...say.. elapsedTime > 1 h .. 
			or ... stdOutStream size > 1MB  or whatever..  "
			aProcess sigterm.
		]
		onExitDo: [ :aProcess :outStream :errStream  |
			process closeAndCleanStreams.
			exited := true.
		].

	self assert: exited.	
	self assertStreamsInfoWithPrevious: streamsInfo.
