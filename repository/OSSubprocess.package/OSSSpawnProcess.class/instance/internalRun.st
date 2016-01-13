running
internalRun
	| pidtPointer returnValue internalError  |
	pidtPointer := NativeBoost allocate: 4.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	returnValue := self primitivePosixSpawn: pidtPointer command: self command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument.
	(returnValue > 0) 
		ifTrue: [ 
			internalError := self primitiveStrerror: returnValue.
			self error: 'Failed in posix_spawn(). Error code: ', returnValue asString, ', description: ', internalError.
		].
	childPid := pidtPointer nbInt32AtOffset: 0.
	