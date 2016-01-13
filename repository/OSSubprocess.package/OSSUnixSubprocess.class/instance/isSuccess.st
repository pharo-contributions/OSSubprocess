status
isSuccess
	^ self isComplete and: [ self exitStatusInterpreter exitStatus = 0 ]