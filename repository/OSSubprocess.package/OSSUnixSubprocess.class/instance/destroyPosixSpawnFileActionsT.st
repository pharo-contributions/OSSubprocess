close and dup2
destroyPosixSpawnFileActionsT
	posixSpawnFileActionsT ifNotNil: [ 
		| returnValue |
		returnValue := self primitivePosixSpawnFileActionsDestroy: posixSpawnFileActionsT. 
		returnValue = 0 ifFalse: [ OSSSystemAccessor current strerror: returnValue message: 'posix_spawn_file_actions_distroy()'. ].	
	].