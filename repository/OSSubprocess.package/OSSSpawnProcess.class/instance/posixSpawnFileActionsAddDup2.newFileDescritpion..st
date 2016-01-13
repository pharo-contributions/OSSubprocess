close and dup
posixSpawnFileActionsAddDup2: oldFileDescription newFileDescritpion: newFileDescription
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddDup2: posixSpawnFileActionsT oldFileDescription: oldFileDescription newFileDescritpion: newFileDescription.
	returnValue = 0 ifFalse: [ 
		| internalError |
		internalError := self primitiveStrerror: returnValue.
		self error: 'Failed in posix_spawn_file_actions_adddup2(). Error code: ', returnValue asString, ', description: ', internalError.
	].
	^ returnValue

