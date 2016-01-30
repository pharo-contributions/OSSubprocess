tests
testBasicCommandWriteToStdin
	| command stdOutString string streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	string := 'this is a test shat should have been printed in the stdout'.
	command := self newCommand
					command: '/bin/cat';
					redirectStdin;
					redirectStdout.
					
	command run.
	command stdinStream 
		nextPutAll: string;
		close.
	command waitForExit.
	command stdoutStream reopen.
	stdOutString := command stdoutStream upToEnd.
	command closeAndCleanStreams.
	self assert: command isSuccess.
	self assert: stdOutString equals: string.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	
