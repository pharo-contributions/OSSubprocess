tests
testBasicCommandWithArgument
	| command | 
	
	command := OSSSpawnProcess new 
					command: '/bin/ls';
					arguments: { Smalltalk image imagePath. }.
	
	self shouldnt: [ command run ] raise: Error. 
	
