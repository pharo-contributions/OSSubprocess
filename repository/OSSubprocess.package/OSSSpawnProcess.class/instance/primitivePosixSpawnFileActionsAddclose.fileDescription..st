private - primitives
primitivePosixSpawnFileActionsAddclose: fileActions fileDescription: fileDescriptionNumber
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode >
	 ^ self nbCall: #( int posix_spawn_file_actions_addclose ( OSSPosixSpawnFileActionsT fileActions, int fileDescriptionNumber) )