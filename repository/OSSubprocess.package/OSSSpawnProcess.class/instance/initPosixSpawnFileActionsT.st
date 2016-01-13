close and dup
initPosixSpawnFileActionsT
	| returnValue |
	posixSpawnFileActionsT := OSSPosixSpawnFileActionsT new 
													handle: ((NativeBoost allocate: 4) value);
													yourself.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ 
		| internalError |
		internalError := self primitiveStrerror: returnValue.
		self error: 'Failed in posix_spawn_file_actions_init(). Error code: ', returnValue asString, ', description: ', internalError.
	 ].
