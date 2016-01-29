tests
testBasicCommandWriteToStdin
	| command stdOutString string streamsInfo stdinStream | 
	streamsInfo := self getStreamsInfoForRunningTest.
	stdinStream := OSSUnixSubprocess createTempFileToBeUsedAsReadStreamOn: '/tmp'. 
	string := 'this is a test shat should have been printed in the stdout'.
	stdinStream 
		nextPutAll: string;
		reopen.
	command := self newCommand
					command: '/bin/cat';
					redirectStdout;
					redirectStdinTo: stdinStream.		
	command run.
	stdinStream close. 
	command waitForExit.
	command stdoutStream reset. 
	stdOutString := command stdoutStream upToEnd.
	command closeAndCleanStreams.
	self assert: command isSuccess.
	self assert: stdOutString equals: string.
	self assertStreamsInfoWithPrevious: streamsInfo.
	
	
