running
commandPreparedToBeRun
	^ self redirectSdErrToStdOut 
		ifTrue: [ self command, ' 2>&1 ' ]
		ifFalse: [ self command ]