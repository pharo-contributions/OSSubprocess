tests - basic
testBasicCommand
	| command |
	command := self newCommand 
					command: '/bin/ls'.
	command run.
	