tests
testReadingOutputPipeBlockVM
	| command | 
	
	command := OSSPopenCommand new 
					beRead;
					command: 'sleep 10; echo "testing"'.
	
	self shouldnt: [ command run ] raise: Error. 
	self assert:[ command pipeStream upToEndOfFile ] timeToRun seconds > 8. 
	command closeStreams.
	self assert: command terminationStatus equals: 0