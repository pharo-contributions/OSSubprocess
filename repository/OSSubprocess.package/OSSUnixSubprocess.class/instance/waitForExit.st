status
waitForExit
	"Does an image-based polling which uses pidwait with WNOHANG to check status of child process.
	Calling #waitForChild is needed so that the child process does not become a zombie after it has finished.
	Answers the exit status of the child."
	| delay |
	delay := Delay forMilliseconds: 50.
	[
		"nil answer means the child has not yet finished" 
		self queryExitStatus isNil
	]
	whileTrue: [ delay wait ].
	^ exitStatus  