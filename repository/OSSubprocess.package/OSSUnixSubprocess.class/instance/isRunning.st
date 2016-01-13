child status
isRunning
	^ childPid notNil and: [ self completed not ]