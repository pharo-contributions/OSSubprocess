pipes
createAndSetStdinPipe
	| pipe | 
	pipe := OSSSystemAccessor current makePipe.
	self posixSpawnFileActionsAddClose: pipe writeEndFileDescriptor.
	self posixSpawnFileActionsAddDup2: pipe readEndFileDescriptor newFileDescritpion: 0.
	self posixSpawnFileActionsAddClose: pipe readEndFileDescriptor.	
	stdinPipe := pipe.
	