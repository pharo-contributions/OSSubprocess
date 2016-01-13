tests
testBasicCommandReadPipe
	| command resultString | 
	
	command := OSSPopenCommand new 
					beRead;
					command: ('ls -la ', Smalltalk image imagePath).
	
	self shouldnt: [ command run ] raise: Error. 				
	resultString := command pipeStream upToEndOfFile. 
	self assert: (resultString includesSubstring: Smalltalk image imagePath).
	self assert: resultString size > (Smalltalk image imagePath size + 10).
	command closeStreams.
	self assert: command terminationStatus equals: 0
	