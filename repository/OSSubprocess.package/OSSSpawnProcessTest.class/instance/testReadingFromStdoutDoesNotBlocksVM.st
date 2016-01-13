tests - streams
testReadingFromStdoutDoesNotBlocksVM
	| command customPipe | 
	customPipe := OSSSystemAccessor current makeNoneBlockingReadPipe.
	command := OSSSpawnProcess new
					command: '/bin/sleep';
					arguments: (Array with: '4');
					stdoutPipe: customPipe.
	
	self shouldnt: [ command run ] raise: Error. 
	self assert: [ command stdoutStream upToEnd ] timeToRun seconds <= 2. 
	