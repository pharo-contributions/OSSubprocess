initialize - release
initializeSignalHandlers
	self flag: #fixIt. "hack!!!!"
	Smalltalk at: #OSProcess ifPresent: [ 
		OSProcess thisOSProcess processAccessor restoreSigChld. 
		OSProcess thisOSProcess processAccessor grimReaperProcess terminate.
		Smalltalk removeFromShutDownList: ThisOSProcess.
		Smalltalk removeFromStartUpList: ThisOSProcess.
	].
	self sigChldSemaphore.
	