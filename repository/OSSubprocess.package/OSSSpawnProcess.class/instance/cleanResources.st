cleaning
cleanResources
	
	self destroyPosixSpawnFileActionsT.
	self closeNoneUsedEndsFromPipes.
	self freePointers.