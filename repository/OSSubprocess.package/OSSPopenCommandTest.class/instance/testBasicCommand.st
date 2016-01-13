tests
testBasicCommand
	| command | 
	
	command := OSSPopenCommand new 
					beRead;
					command: 'ls'.
	
	self shouldnt: [ command run ] raise: Error. 
	command closeStreams.
	self assert: command terminationStatus equals: 0