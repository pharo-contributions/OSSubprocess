private - primitives
primitivePosixSpawnFileActionsAddDup2: fileActions oldFileDescription: oldFileDescription newFileDescritpion: newFileDescription 
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode >
	 ^ self nbCall: #( int posix_spawn_file_actions_adddup2 ( OSSPosixSpawnFileActionsT fileActions, int oldFileDescription, int newFileDescription ) )