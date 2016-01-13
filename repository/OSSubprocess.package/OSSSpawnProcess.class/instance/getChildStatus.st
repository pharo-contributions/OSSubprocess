child testing
getChildStatus
	| returnValue statusPointer internalError |
	self childPid ifNil: [ self error: 'Cannot ask child status if child was not successfully created' ].
	statusPointer := NativeBoost allocate: 4.
	"The option 1 is to simulate the WNOHANG which we neet to set... We cannot guarantee it will be 1 in every possible 
	POSIX OS, but we will assume that for the time being. See public thread with subject 'Can I access symbolic constants from NB FFI?'. "
	returnValue := self primitiveWaitpid: self childPid statusPointer: statusPointer options: 1.
	statusPointer free.
	
	(returnValue = -1) ifTrue: [ 
		self primitivePerror: 'waitpid()'.
		internalError := self primitiveStrerror: returnValue.
		self error: 'Failed in waitpid(). Error code: ', returnValue asString, ', description: ', internalError.
	]. 
	returnValue = 0 ifTrue: [ ^ nil ]. "If waitpid() was invoked with WNOHANG set in options, it has at least one child process specified by pid for which status is not available, and status is not available for any process specified by pid, 0 is returned.
	That means...status is not available for childPid..probably hasn't finished yet."
	(returnValue = self childPid) ifTrue: [ 
		"If wait() or waitpid() returns because the status of a child process is available, these functions shall return a value equal to the process ID of the child process for which status is reported.
		This means...status is available"
		^ (OSSUnixProcessExitStatus for: (statusPointer nbInt32AtOffset: 0)).
	
	] .
	
	"^ ThisOSProcess thisOSProcess processAccessor primGetChildExitStatus: self childPid
	"
