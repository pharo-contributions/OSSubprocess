tests - basic
testBasicCommandWithNonAsciiArgument
	| command | 
	
	self withNonAsciiDirectoryDo: [ :dir |
		command := self newCommand
					command: '/bin/ls';
					arguments: { dir fullName }.
		command runAndWait
	]
