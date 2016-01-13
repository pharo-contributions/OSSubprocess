close and dup
closeAndDup2FilesActions
	self initPosixSpawnFileActionsT.
	self closeAllButStandardFileStreams.
	self dup2StandardFileStreams.
	