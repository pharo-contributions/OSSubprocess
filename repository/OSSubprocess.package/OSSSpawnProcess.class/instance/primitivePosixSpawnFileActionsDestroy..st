private - primitives
primitivePosixSpawnFileActionsDestroy: aPosixSpawnFileActionsT 
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( int posix_spawn_file_actions_destroy(OSSPosixSpawnFileActionsT  aPosixSpawnFileActionsT) )
	


