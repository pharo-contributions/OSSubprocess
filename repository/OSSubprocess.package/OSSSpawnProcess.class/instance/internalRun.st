running
internalRun
	| pidtPointer returnValue   |
	pidtPointer := NativeBoost allocate: 4.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	returnValue := self primitivePosixSpawn: pidtPointer command: self command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument.
	(returnValue > 0) 
		ifTrue: [ self strerror: returnValue message: 'posix_spawn()'. ].
	childPid := pidtPointer nbInt32AtOffset: 0.
	