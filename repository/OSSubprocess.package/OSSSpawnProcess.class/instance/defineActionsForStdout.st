close and dup2
defineActionsForStdout
	
	self shouldCreatePipeFor: stdoutPipe ifTrue: [ stdoutPipe := self createADefaultPipe ].
	stdoutPipe ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stdoutPipe readEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stdoutPipe writeEndFileDescriptor newFileDescritpion: 1.
		self posixSpawnFileActionsAddClose: stdoutPipe writeEndFileDescriptor.	
	]