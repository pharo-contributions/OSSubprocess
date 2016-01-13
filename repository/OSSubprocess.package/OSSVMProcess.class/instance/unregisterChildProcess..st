childs management
unregisterChildProcess: anOSProcess

	accessProtect critical: [childProcessList remove: anOSProcess ifAbsent: [] ].
	^ anOSProcess
