close and dup2
initPosixSpawnFileActionsT
	| returnValue |
	posixSpawnFileActionsT := ExternalAddress allocate: 76.
	self registerPointer: posixSpawnFileActionsT.
	returnValue := self primitivePosixSpawnFileActionsInit: posixSpawnFileActionsT. 
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_init()' ].