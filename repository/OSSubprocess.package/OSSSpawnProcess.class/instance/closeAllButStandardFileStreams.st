close and dup
closeAllButStandardFileStreams
	"Here I should loop and close all but fd 0 1 2"

	"returnValue := self primitivePosixSpawnFileActionsAddclose: posixSpawnFileActionsTPointer fileDescription: 1.
	returnValue = 0 ifFalse: [ 
		| internalError |
		internalError := self primitiveStrerror: returnValue.
		self error: 'Failed in posix_spawn_file_actions_addclose(). Error code: ', returnValue asString, ', description: ', internalError.
	]."
	