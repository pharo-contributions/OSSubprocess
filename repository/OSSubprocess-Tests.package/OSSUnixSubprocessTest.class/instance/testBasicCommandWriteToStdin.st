tests - streams
testBasicCommandWriteToStdin
	| command stdOutString string streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	string := 'this is a test shat should have been printed in the stdout'.
	command := self newCommand
					command: '/bin/cat';
					redirectStdin;
					redirectStdout.
					
	command run.
	(Delay forSeconds: 2) wait. 
	command stdinStream 
		nextPutAll: string;
		close.
	command waitForExit.
	stdOutString := command stdoutStream upToEnd.
	command closeAndCleanStreams.
	self assert: command isSuccess.
	self assert: stdOutString equals: string.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	
