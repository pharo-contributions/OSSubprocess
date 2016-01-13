close and dup2
defineActionsForStdin
	
	self shouldCreatePipeFor: stdinPipe ifTrue: [ stdinPipe := self createADefaultPipe ].
	stdinPipe ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stdinPipe writeEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stdinPipe readEndFileDescriptor newFileDescritpion: 0.
		self posixSpawnFileActionsAddClose: stdinPipe readEndFileDescriptor.	
	]	
		