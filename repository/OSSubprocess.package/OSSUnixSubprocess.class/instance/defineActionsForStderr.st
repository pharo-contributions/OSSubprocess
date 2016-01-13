close and dup2
defineActionsForStderr
	
	self shouldCreateStreamFor: stderrStream ifTrue: [ stderrStream := self createADefaultWriteStream ].
	self defineActionsForWriteStream: stderrStream dupTo: 2