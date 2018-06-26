child watching
checkFinishedChildren
	"Does a waitpid() with the flag WNOHANG which makes the system call to answer immediatly rather than waiting until child has exited. 
	Answers nil if child has not yet exited or the exit status if it has.
	
	http://man7.org/linux/man-pages/man2/waitpid.2.html
	waitpid man's page is ambiguous with respect of the usage of the WNOHANG option.
	It looks like waitpid ignores the first argument if WNOHANG is specified, and returns with ANY child process id.
	This means that, in combination with the previous issue, it may happen that calling waitpid for process X will unregister process Y, what will make fail a subsequent call to waitpid from Y.
	"

	| waitedChildren childrenSize |
	"Skip checking if we have no children"
	waitedChildren := 0.
	childrenSize := self activeChildren size.
	[ waitedChildren < childrenSize ]
		whileTrue: [ | statusPointer |
			[ | status returnValue |
			statusPointer := ExternalAddress allocate: systemAccessor sizeOfInt.
			returnValue := self primitiveWaitpid: -1 statusPointer: statusPointer options: WNOHANG.

			"If return value is 0 then there are no more changes, we can exit"
			returnValue = 0
				ifTrue: [ ^ self ].

			"Only throw error in case it is an error other than no childs (represented as return -1 and errno=ECHILD)"
			returnValue = -1
				ifTrue: [ systemAccessor perror: 'waitpid()' ].
			waitedChildren := waitedChildren + 1.
			status := statusPointer platformLongAt: 1.
			self updateChildProcessWithId: returnValue withStatus: status ]
				ensure: [ statusPointer free ] ]