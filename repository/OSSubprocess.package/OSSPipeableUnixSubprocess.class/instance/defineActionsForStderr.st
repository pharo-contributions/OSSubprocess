close and dup2
defineActionsForStderr
	
	self shouldCreateStreamFor: stderrStream ifTrue: [ stderrStream := self createADefaultStream ].
	stderrStream ifNotNil: [ 
		self posixSpawnFileActionsAddClose: stderrStream readEndFileDescriptor.
		self posixSpawnFileActionsAddDup2: stderrStream writeEndFileDescriptor newFileDescritpion: 2.
		self posixSpawnFileActionsAddClose: stderrStream writeEndFileDescriptor.	
	]