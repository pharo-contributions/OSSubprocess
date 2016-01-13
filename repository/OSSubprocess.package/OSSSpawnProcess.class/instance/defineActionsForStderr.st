close and dup2
defineActionsForStderr
	
	self shouldCreatePipeFor: stderrPipe ifTrue: [ stderrPipe := self createADefaultPipe ].
	stderrPipe ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stderrPipe readEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stderrPipe writeEndFileDescriptor newFileDescritpion: 2.
		self posixSpawnFileActionsAddClose: stderrPipe writeEndFileDescriptor.	
	]