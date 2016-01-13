cleaning
cleanResources
	
	self destroyPosixSpawnFileActionsT.
	self cleanAndFixCopiedStreams.
	self freePointers.