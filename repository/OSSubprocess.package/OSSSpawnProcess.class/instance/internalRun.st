running
internalRun
	| pidtPointer envPointer returnValue internalError  |
	pidtPointer := NativeBoost allocate: 4.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	
	envPointer := NBExternalAddress value: ((NativeBoost loadSymbol: 'environ' fromModule: NativeBoost CLibrary) nbUInt32AtOffset: 0).
	returnValue := self primitivePosixSpawn: pidtPointer command: self command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self primitiveArguments envPointer: envPointer.

	(returnValue > 0) 
		ifTrue: [ 
			internalError := self primitiveStrerror: returnValue.
			self error: 'Failed in posix_spawn(). Error code: ', returnValue asString, ', description: ', internalError.
		]
		ifFalse: [ 
			childPid := pidtPointer nbInt32AtOffset: 0 ].
		