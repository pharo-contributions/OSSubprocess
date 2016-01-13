close and dup2
posixSpawnFileActionsAddDup2: oldFileDescription newFileDescritpion: newFileDescription
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddDup2: posixSpawnFileActionsT oldFileDescription: oldFileDescription newFileDescritpion: newFileDescription.
	returnValue = 0 ifFalse: [ self systemAccessor strerror: returnValue message: 'posix_spawn_file_actions_adddup2()' ].
	^ returnValue

