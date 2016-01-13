close and dup2
closeAndDup2FilesActions
	self initPosixSpawnFileActionsT.
	self closeAllButStandardFileStreams.
	self defineActionsForStandardFileStreams.
	