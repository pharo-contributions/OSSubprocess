waiting
"waiting"
waitpidNoHang: childPidInteger
	"Does a waitpid() with the given childPidInteger. The wait is with the flag WNOHANG which makes
	the system call to answer immediatly rather than waiting until child has exited. 
	Answers nil if child has not yet exited or the exit status if it has. 
	"
	
	| statusPointer |
	childPidInteger ifNil: [ self error: 'Cannot waitpid if pid is invalid' ].

	finishedChildProcesses at: childPidInteger ifPresent: [ :status |
		finishedChildProcesses removeKey: childPidInteger.
		^ status ].
	
	
	statusPointer := ExternalAddress allocate: self sizeOfInt.
	[ | returnValue status |
		returnValue := self primitiveWaitpid: childPidInteger statusPointer: statusPointer options: WNOHANG.

		(returnValue = -1) ifTrue: [ self perror: 'waitpid()'. ]. 
		returnValue = 0 ifTrue: [ ^ nil ]. "If waitpid() was invoked with WNOHANG set in options, it has at least one child process specified by pid for which status is not available, and status is not available for any process specified by pid, 0 is returned.
		That means...status is not available for childPidInteger..probably hasn't finished yet."
		
		
		"If wait() or waitpid() returns because the status of a child process is available, these functions shall return a value equal to the process ID of the child process for which status is reported.
		This means...status is available. It has finished. "
		"If this returned PID is the asked one we return the given status, otherwise we store it in the finishedChildProcesses table and return nil"
		status := statusPointer platformLongAt: 1.
		^ (returnValue = childPidInteger)
			ifTrue: [ status ]
			ifFalse: [
				finishedChildProcesses at: childPidInteger put: status.
				nil ].
	] ensure: [ statusPointer free ]
	