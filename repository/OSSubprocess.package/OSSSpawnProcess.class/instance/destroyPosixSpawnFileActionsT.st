close and dup
destroyPosixSpawnFileActionsT
	posixSpawnFileActionsT ifNotNil: [ 
		| returnValue |
		returnValue := self primitivePosixSpawnFileActionsDestroy: posixSpawnFileActionsT. 
		returnValue = 0 ifFalse: [ 
			| internalError |
			internalError := self primitiveStrerror: returnValue.
			self error: 'Failed in posix_spawn_file_actions_distroy(). Error code: ', returnValue asString, ', description: ', internalError.
		].	
	].