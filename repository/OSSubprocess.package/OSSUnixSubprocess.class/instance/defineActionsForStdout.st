close and dup2
defineActionsForStdout
	
	self shouldCreateStreamFor: stdoutStream ifTrue: [ stdoutStream := self createADefaultWriteStream ].
	self defineActionsForWriteStream: stdoutStream dupTo: 1