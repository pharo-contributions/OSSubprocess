private - primitives
primitivePosixSpawn: pidPointer command: commandString fileActions: fileActions attributes: attributes argPointer: argPointer envPointer: envPointer
	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode >
	 ^ self nbCall: #( int posix_spawn (NBExternalAddress pidPointer, String commandString, OSSPosixSpawnFileActionsT fileActions, void * attributes, NBExternalAddress argPointer, NBExternalAddress envPointer) ) 
				module: NativeBoost CLibrary 
			 options: #(+ optCoerceNilToNull)