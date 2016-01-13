close and dup2
defineActionsForStdin
	
	self shouldCreateStreamFor: stdinStream ifTrue: [ stdinStream := self createADefaultStream ].
	stdinStream ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stdinStream writeEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stdinStream readEndFileDescriptor newFileDescritpion: 0.
		self posixSpawnFileActionsAddClose: stdinStream readEndFileDescriptor.	
	]	
		