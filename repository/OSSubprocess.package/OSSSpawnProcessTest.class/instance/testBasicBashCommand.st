tests - bash
testBasicBashCommand
	| command | 
	
	command := OSSSpawnProcess new 
					bashCommand: 'ls'.
	
	self shouldnt: [ command run ] raise: Error. 
	