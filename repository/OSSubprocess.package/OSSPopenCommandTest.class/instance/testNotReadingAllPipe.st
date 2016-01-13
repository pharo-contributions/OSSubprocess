tests
testNotReadingAllPipe
	| command | 
	
	command := OSSPopenCommand new 
					beRead;
					command: 'ls'.
	
	self shouldnt: [ command run ] raise: Error. 
	command closeStreams.
	self assert: command terminationStatus > 0