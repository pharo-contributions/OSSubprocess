status
setExitStatus: aStatus
	"This method set's the current process exit status.
	If exitStatus was already set it will fail.
	
	This method is synchronized to avoid race conditions on the access to the exit status"
	waitPidCriticalSemaphore critical: [
		exitStatus ifNotNil: [ self error: 'Modification not allowed' ].
		exitStatus := aStatus
	]
		