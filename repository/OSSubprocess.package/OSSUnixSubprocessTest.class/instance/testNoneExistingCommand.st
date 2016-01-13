tests - basic
testNoneExistingCommand
	| command | 
	
	command := self newCommand
					command: 'whatever'.
	
	self should: [ command run ] raise: Error.
	[ command run ] on: Error do: [ :ex | 
		self assert: (ex printString includesSubstring: 'No such file or directory') ].
	self assert: command childPid isNil.
