tests
testNoneExistingCommand
	| command | 
	
	command := OSSSpawnProcess new 
					command: 'whatever'.
	
	self should: [ command run ] raise: Error.
	[ command run ] on: Error do: [ :ex | ex printString includesSubstring: 'No such file or directory' ].
	command childPid isNil
