running
internalRun
	| pidtPointer returnValue   |
	pidtPointer := ExternalAddress allocate: 4.
	self registerPointer: pidtPointer.
	self closeAndDup2FilesActions.
	pwd 
		ifNil: [ returnValue := self primitivePosixSpawn: pidtPointer command: command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument. ] 
		ifNotNil: [ 
			self systemAccessor
				lockCwdWithValue: pwd 
				during: [ returnValue := self primitivePosixSpawn: pidtPointer command: command fileActions: posixSpawnFileActionsT attributes: nil argPointer: self buildPrimitiveArgVArgument envPointer: self buildPrimitiveEnvArgument. ]
		].
	(returnValue > 0) 
		ifTrue: [ self systemAccessor strerror: returnValue message: 'posix_spawn()'. ].
	pid := pidtPointer nbInt32AtOffset: 0.
	OSSVMProcess vmProcess registerChildProcess: self.
	