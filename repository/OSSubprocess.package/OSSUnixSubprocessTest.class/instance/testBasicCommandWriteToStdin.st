tests - streams
testBasicCommandWriteToStdin
	| command stdOutString string streamsInfo | 
	streamsInfo := self getStreamsInfoForRunningTest.
	string := 'this is a test shat should have been printed in the stdout'.
	command := self newCommand
					command: '/bin/cat';
					createAndSetStdinStream;
					createAndSetStdoutStream.
					
	command run.
	command stdinStream 
		nextPutAll: string;
		close.
	command waitForChild.
	stdOutString := command stdoutStream upToEnd.
	command closeAndCleanStreams.
	self assert: stdOutString equals: string.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	
