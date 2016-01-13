tests
testBasicCommandWithArgument
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: { Smalltalk image imageName. }.
	
	self shouldnt: [ command run ] raise: Error. 
	
