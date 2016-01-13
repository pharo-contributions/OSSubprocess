running
internalRun
	| pidtPointer returnValue   |
	pidtPointer := ExternalAddress allocate: 4.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	returnValue := self primitivePosixSpawn: pidtPointer command: self command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument.
	(returnValue > 0) 
		ifTrue: [ OSSSystemAccessor current strerror: returnValue message: 'posix_spawn()'. ].
	childPid := pidtPointer nbInt32AtOffset: 0.
	