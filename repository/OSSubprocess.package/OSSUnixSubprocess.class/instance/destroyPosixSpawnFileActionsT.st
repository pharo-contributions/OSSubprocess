close and dup2
destroyPosixSpawnFileActionsT
	posixSpawnFileActionsT ifNotNil: [ 
		| returnValue |
		returnValue := self primitivePosixSpawnFileActionsDestroy: posixSpawnFileActionsT. 
		returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_distroy()'. ].	
	].