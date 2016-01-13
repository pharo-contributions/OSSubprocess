pipes
createAndSetStderrPipe
	| pipe | 
	pipe := OSSSystemAccessor current makePipe.
	self posixSpawnFileActionsAddClose: pipe readEndFileDescriptor.
	self posixSpawnFileActionsAddDup2: pipe writeEndFileDescriptor newFileDescritpion: 2.
	self posixSpawnFileActionsAddClose: pipe writeEndFileDescriptor.	
	stderrPipe := pipe.
	