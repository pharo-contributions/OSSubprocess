cleaning
cleanResources
	
	self destroyPosixSpawnFileActionsT.
	self closeStreams.
	self freePointers.