close and dup
initPosixSpawnFileActionsT
	| returnValue |
	posixSpawnFileActionsT := OSSPosixSpawnFileActionsT new 
													handle: ((NativeBoost allocate: 4) value);
													yourself.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ self strerror: returnValue message: 'posix_spawn_file_actions_init()' ].
