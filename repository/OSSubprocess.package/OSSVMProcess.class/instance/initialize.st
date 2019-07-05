initialize - release
initialize
	"Set my instance variables to reflect the state of the OS process in which 
	this Smalltalk virtual machine is. executing."
	Smalltalk os isWindows ifTrue: [ ^ self ]. "Cannot be initialized nor used on Windows."

	accessProtect := Semaphore forMutualExclusion.
	mutexForCwd := Semaphore forMutualExclusion.
	self initializeAllMyChildren.
	systemAccessor := OSSUnixSystemAccessor forVMProcess. 
	pid := systemAccessor getPid.
	childListTreshold := 20. "Once child list gets bigger than this number, we delete all exited processes"
	self initializeSessionID.
	self initializeSignalHandlers.
	self initializeChildWatcher.