close and dup2
posixSpawnFileActionsAddClose: aFileDescription 
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddClose: posixSpawnFileActionsT fileDescription: aFileDescription.
	returnValue = 0 ifFalse: [ OSSSystemAccessor current strerror: returnValue message: 'posix_spawn_file_actions_adddclose()' ].
	^ returnValue

