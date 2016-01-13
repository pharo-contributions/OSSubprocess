pipes
createAndSetStdoutPipe
	| cFile fileDescriptions | 
	fileDescriptions := self createPipe.
	self posixSpawnFileActionsAddClose: fileDescriptions first.
	self posixSpawnFileActionsAddDup2: fileDescriptions second newFileDescritpion: 1.
	self posixSpawnFileActionsAddClose: fileDescriptions second.	
	cFile := self fdopen: fileDescriptions first mode: 'r'.
	stdoutStream := OSSAttachableFileStream name: 'pipeStdoutReader' attachTo: cFile writable: false.
	fileDescriptionsToClose add: fileDescriptions second

	

