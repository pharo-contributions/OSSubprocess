cleaning
cleanResources
	
	self destroyPosixSpawnFileActionsT.
	self extraResourcesCleanup.
	self freePointers.