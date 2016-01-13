tests
testClosingPipeBlockVM
	| command | 
	
	command := OSSPopenCommand new 
					beRead;
					command: 'sleep 10; echo "testing"'.
	
	self shouldnt: [ command run ] raise: Error. 
	self assert:[ command closeStreams ] timeToRun seconds > 8. 
