private - primitives
primitivePosixSpawnFileActionsInit: aPosixSpawnFileActionsT 
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin>
	^ self nbCall: #( int posix_spawn_file_actions_init(OSSPosixSpawnFileActionsT  aPosixSpawnFileActionsT) )
	
