tests
testBasicCommandReadPipe
	| command resultString | 
	
	command := OSSPopenCommand new 
					beRead;
					command: ('ls -la ', Smalltalk image imageName).
	
	self shouldnt: [ command run ] raise: Error. 				
	resultString := command pipeStream upToEndOfFile. 
	self assert: (resultString includesSubstring: Smalltalk image imageName).
	self assert: resultString size > (Smalltalk image imageName size + 10).
	command closeStreams.
	self assert: command terminationStatus equals: 0
	