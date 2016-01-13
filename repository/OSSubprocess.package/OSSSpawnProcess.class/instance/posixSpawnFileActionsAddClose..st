close and dup
posixSpawnFileActionsAddClose: aFileDescription 
	| returnValue |
	returnValue := self primitivePosixSpawnFileActionsAddClose: posixSpawnFileActionsT fileDescription: aFileDescription.
	returnValue = 0 ifFalse: [ 
		| internalError |
		internalError := self primitiveStrerror: returnValue.
		self error: 'Failed in posix_spawn_file_actions_adddclose(). Error code: ', returnValue asString, ', description: ', internalError.
	].
	^ returnValue

