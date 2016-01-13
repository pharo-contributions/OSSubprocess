status
isRunning
	^ pid notNil and: [ self isComplete not ]