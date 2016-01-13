close and dup2
defineActionsForStdin
	
	self shouldCreateStreamFor: stdinStream ifTrue: [ stdinStream := self createADefaultReadStream ].
	self defineActionsForReadStream: stdinStream dupTo: 0