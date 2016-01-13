close and dup2
defineActionsForStdout
	
	self shouldCreateStreamFor: stdoutStream ifTrue: [ stdoutStream := self createADefaultStream ].
	stdoutStream ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stdoutStream readEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stdoutStream writeEndFileDescriptor newFileDescritpion: 1.
		self posixSpawnFileActionsAddClose: stdoutStream writeEndFileDescriptor.	
	]