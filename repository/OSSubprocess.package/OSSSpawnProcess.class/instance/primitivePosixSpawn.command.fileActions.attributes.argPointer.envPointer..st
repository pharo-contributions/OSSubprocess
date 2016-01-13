private - primitives
primitivePosixSpawn: pidPointer command: commandString fileActions: fileActions attributes: attributes argPointer: argPointer envPointer: envPointer
	 ^ self ffiCall: #( int posix_spawn (void* pidPointer, String commandString, OSSPosixSpawnFileActionsT fileActions, void * attributes, void* argPointer, void* envPointer) ) 
				module: 'libc'
				options: #(+ optCoerceNilToNull)
			
		