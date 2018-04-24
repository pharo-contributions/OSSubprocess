tests - wait
testCommandReturningDifferentThanZero
	| command | 
	
	"When the file does not exists ls returns 1"
	command := self newCommand 
					command: '/bin/ls';
					arguments: {'asdasdasdasdsad'}.
	
	command runAndWait. 
	self deny: (command exitStatusInterpreter exitStatus = 0). 