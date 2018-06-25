childs management
registerChildProcess: anOSProcess
	"Unregister anOSProcess, and trim the child process registry to prevent excessive
	accumulation of exited children.
	
	If the process finished before this registration, set it the exit status.
	Otherwise, register it"

	accessProtect critical: [ 
		self earlyFinishedProcesses
			at: anOSProcess pid
			ifPresent: [ :exitStatus |
				anOSProcess setExitStatus: exitStatus.
				self earlyFinishedProcesses removeKey: anOSProcess pid ]
			ifAbsent: [ childProcessList addFirst: anOSProcess ] ].
	self pruneExitedChildrenAfter: childListTreshold.
	^ anOSProcess
	